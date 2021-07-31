// SPDX-License-Identifier: GPL-3.0
/*
Create Crypto Bank Contract

    1) The owner can start the bank with initial deposit/capital in ether (min 50 eths)                     DONE
    2) Only the owner can close the bank. Upon closing the balance should return to the Owner               DONE
    3) Anyone can open an account in the bank. For Account opening they need to deposit ether with address  DONE
    4) Bank will maintain balances of accounts                                                              DONE
    5) Anyone can deposit in the bank                                                                       DONE
    6) Only valid account holders can withdraw                                                              DONE
    7) First 5 accounts will get a bonus of 1 ether in bonus                                                DONE
    8) Account holder can inquiry balance                                                                   DONE
    9) The depositor can request for closing an account                                                     DONE
*/

/* Note:
    (1) Throughout the program I have used ether as unit. Values passed are expected to be in ether (not dinominations 
        like wei, gwei etc) and similarly returned values are in ether. Sometimes using "1 ether" and sometimes "1e18" 
        or "10**18" as divider or multiplier for conversion.
    (2) Since bonus amount cannot be more than 5 ethers and minimum initial capital is 50 ethers, therfore didn't check
        if bonus exceedes available capital or not.
*/

pragma solidity ^0.8.0;

contract CryptoBank {
    
    struct BankAccount {
        
        uint256 accountNumber;  // This counter will serve two objectives 
                                // (1) Additional key other than address 
                                // (2) Verify if there is already an account for the requested address
                                
        uint256 accountBalance; // This variable stores current balance of the account
        
        bool isActive;          // This variabl check wheather the account is active or not
    }
    
    mapping (address => BankAccount) accountsLedger;    // List data of all accounts opened with the bank
    
    uint256 accountNumberCounter = 0;                   // Counter, also used to grant 1 ether to first 5 accounts
    
    uint256 minimumInitialCapital = (10 ether);
    
    address payable owner;

    constructor () payable {
        // The EOA calling this constructor by contract deployment will become owner of the CryptoBank instance.
        // The EOA should provide at least 50 ether along with deployment
        require (msg.value >= minimumInitialCapital, "Minimum Initial Capital should be 50 ethers.");
        owner = payable(msg.sender);
    }
    
    function getCapital () public view returns (uint256) {
        require (msg.sender == owner, "Only bank owner can enquire the capital amount.");
        return address(this).balance / 1e18;
    }
    
    modifier ownerOnly {
        require(msg.sender == owner, "Only the bank owner can close the bank to initiate funds transfer to owner's account.");
        _;
    }

    function closeBank() public payable ownerOnly {
        // although it seems unfair to close bank without returning respective amounts to account holders,
        // I have returned all deposits to the bank owner's account to fulfil the assignment requirement as it is.
        selfdestruct(owner);
    }    

    modifier withDeposit () {
        require (msg.value >= 1 ether, "You must deposit at least 1 ether to open an account.");
        _;
    }

    // This method will open the calling EOA's own bank account.
    function openBankAccount () public payable {
        openBankAccount (msg.sender);
    }
    
    // This method will open an account for given address. Money will be dedcuted from calling EOA.
    function openBankAccount (address _account) public payable withDeposit {

        require (accountsLedger[_account].accountNumber == 0 && !accountsLedger[_account].isActive, "Account with this address has already been opened.");

        uint256 _initialDeposit = msg.value;

        if (accountsLedger[_account].accountNumber > 0) {
        // This address already had an account which only needs to be re-activated.
            accountsLedger[_account].isActive = true;
            accountsLedger[_account].accountBalance = _initialDeposit;
            
        } else {
        // Create a new account
            BankAccount memory newBankAccount = BankAccount (++accountNumberCounter, _initialDeposit, true);
            accountsLedger[_account] = newBankAccount;
            if (accountNumberCounter <= 5) {
            // Allow 1 ether bonus from capital
                accountsLedger[_account].accountBalance += 1 ether;
            }
        }
    }
    
    function deposit () public payable returns (uint256 newBalance) {
        return deposit (msg.sender);
    }
    
    function deposit (address _account) public payable returns (uint256 newBalance) {
        require (accountsLedger[_account].isActive, "You don't have an active account with our bank.");
        uint256 _amount = msg.value;
        accountsLedger[_account].accountBalance += _amount;
        return (accountsLedger[_account].accountBalance / 1 ether);
    }
    
    function withdraw (uint256 _amount) public payable returns (uint256 remainingBalance) {
        address _account = msg.sender;
        require (accountsLedger[_account].isActive, "You don't have an active account with our bank.");
        _amount *= 1e18;
        require (accountsLedger[_account].accountBalance >= (_amount), "Not enough balance.");
        payable(_account).transfer(_amount);
        accountsLedger[_account].accountBalance -= _amount;
        return (accountsLedger[_account].accountBalance  / 1 ether);
    }
    
    function getBankBalance () public view returns (uint256 bankBalance) {
        address _account = msg.sender;
        require (accountsLedger[_account].isActive, "You don't have an active account with our bank.");
        return (accountsLedger[_account].accountBalance / 1 ether);
    }
    
    function closeBankAccount () public {
        address _account = payable(msg.sender);
        require (accountsLedger[_account].isActive, "You don't have an active acount with our bank.");
        payable(_account).transfer(accountsLedger[_account].accountBalance);
        accountsLedger[_account].accountBalance = 0;
        accountsLedger[_account].isActive = false;
        // value of accountsLedger[_account].accountNumber has been left as it is for future validations
    }

    // This is not a required function, only meant for debugging.
    function getMyLedger () public view returns (uint256 accountNumber, uint256 accountBalance, bool isActive) {
        return (accountsLedger[msg.sender].accountNumber, accountsLedger[msg.sender].accountBalance / 1e18, accountsLedger[msg.sender].isActive);
    }
    
}

