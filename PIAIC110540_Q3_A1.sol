/*
Batch	Batch 8
Course	Blockchain
Quarter 3
Assignment 1
Name	Jawad Habibullah Swati
Roll No	PIAIC110540
Email	jawadswati@gmail.com
*/

pragma solidity ^0.8.0;

/*
1) Create a first "ParentVehicle" contract that includes the following functions
start - returns String message” The Vehicle has just Started”
accelerate - returns String message” The Vehicle has just Accelerated”
stop -- returns String message” The Vehicle has just Stopped”
service- returns String message” The Vehicle is being serviced”
*/
contract ParentVehicle {
    function start () pure public returns (string memory) {
        return "The Vehicle has just Started";
    }
    
    function accelerate () pure public returns (string memory) {
        return "The Vehicle has just Accelerated";
    }
    
    function stop () pure public returns (string memory) {
        return "The Vehicle has just Stopped";
    }
    
    function service () virtual pure public returns (string memory) {
        return "The Vehicle is being serviced";
    }
}

/*
2) Next Create following Child contracts for a different type of vehicles, that inherits Vehicle
Cars
Truck
MotorCycle,

(The contract shall override the Service Method to return, w Cars/ Truck/ Motor Cycle is being serviced)

*/
contract Car is ParentVehicle {
    function service () virtual override pure public returns (string memory) {
        return "The Car is being serviced";
    }
}

contract Truck is ParentVehicle {
    function service () virtual override pure public returns (string memory) {
        return "The Truck is being serviced";
    }
}

contract MotorCycle is ParentVehicle {
    function service () virtual override pure public returns (string memory) {
        return "The MotorCycle is being serviced";
    }
}

/*
3) Then create smart contracts for “Alto Mehran, “ Hino, Yamaha, that may inherit the relevant smart contract(s) as in step 2.
*/
contract AltoMehran is Car {
    function service () override pure public returns (string memory) {
        return "The Alto Mehran Car is being serviced";
    }
}

contract Hino is Truck {
    function service () override pure public returns (string memory) {
        return "The Hino Truck is being serviced";
    }
}

contract Yamaha is MotorCycle {
    function service () override pure public returns (string memory) {
        return "The Yamaha MotorCycle is being serviced";
    }
    
}

/*
4)
Create 3 Service Stations for each vehicle type, with the same
function “vehicleService that takes the address of the deployed
contracts of step 3, in the “Vehicle” variable to call the service
function
*/

/*Note about my solution to the 4th question:
    Althought I have created 3 service stations as required 
    but I didn't understand why we had to create 3 separate service stattions 
    when practicaly all we needed was one Service station with a generic method.
    In my solution I made the first service station using address and call approach.
    The other two could be made simply by copying it and renaming the conract. 
    However I made them withouth using the address/call approach. The other two give better view
    of returned value compared to first one.
    
    In short, any of these service stations can be used for any type of vehicle.
    
    What I still need to learn is how to contorl return value behaviour in methods of non-inherited contracts.
    In case of inherited contracts they appear under the method button but not in other cases.
    
*/

contract AltoMehranServiceStation {

    function vehicleService (address vehicle) public returns (string memory s) {
        bytes memory payload = abi.encodeWithSignature("service()");
        (bool success, bytes memory returnData) = vehicle.call(payload);
        require(success);
        return (string(returnData));
        //Returned string can be improved by a method to trim extra bytes.
    }
}

contract HinoServiceStation {

    function vehicleService (ParentVehicle vehicle)  pure public returns (string memory s) {
        return vehicle.service();
    }
}

contract YamahaServiceStation {

    function vehicleService (ParentVehicle vehicle)  pure public returns (string memory s) {
        return vehicle.service();
    }
}

contract testContract {
    function test1 () public returns (string memory s) {
        AltoMehranServiceStation ss1 = new AltoMehranServiceStation ();
        address add = address ( new Yamaha() );
        return ss1.vehicleService(add);
    }

    function test2 () public returns (string memory s) {
        HinoServiceStation sam = new HinoServiceStation ();
        return sam.vehicleService(new Hino());
    }

    function test3 () public returns (string memory s) {
        YamahaServiceStation sam = new YamahaServiceStation ();
        return sam.vehicleService(new Yamaha());
    }

}
