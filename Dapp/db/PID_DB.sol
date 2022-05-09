// SPDX-License-Identifier: GPL-3.0
// ola mundo
pragma solidity >=0.4.0 <0.9.0;

import "../libs/UnorderedKeySet.sol";
// import "./libs/EntitiesLib.sol" as entities;
import "../util/EntitiesLib.sol";
import "../util/UUIDProvider.sol";
// import {Entities.Person} from "./libs/EntitiesLib.sol";

contract PID_DB {
    
    using UnorderedKeySetLib for UnorderedKeySetLib.Set;
    
    
    address private owner;
    UnorderedKeySetLib.Set pid_set;
    mapping(bytes16 => Entities.PID) private pid_db;
    
    

    // logs
    event UUID(bytes16 indexed uuid, address indexed owner, uint timestamp);
    // event LogCreatePerson(address indexed owner, bytes32 indexed id, string indexed name);
    // event LogPerson(address indexed owner, bytes32 indexed id, string indexed name);


    /**
     * @dev Set contract deployer as owner
     *  max indexed 2^256
     */
    constructor() {
        //usar para controle de acesso
        owner = msg.sender; 
    }

    /**
     * Create a researcher. 
     * - _name the researcher name
     * - return Dπ id of the researcher
    **/
    function assing_uuid()
    public 
    returns(bytes16)
    {
        bytes16 uuid;
        bytes16 uuid_alternativo;

        (uuid,uuid_alternativo) = UUIDProvider.getUUID4();

        if ( pid_set.exists(uuid) ){
            uuid = uuid_alternativo;
        } 

        require( !pid_set.exists(uuid), "unable to create unique uuid try again later");

        pid_set.insert(uuid);
        Entities.PID storage pid = pid_db[uuid];
        pid.uuid = uuid;
        pid.owner = msg.sender;

        emit UUID(pid.uuid, pid.owner, block.timestamp);

        return uuid;
    }

    function get_pid(bytes16 uuid)
    public view
    returns(Entities.PID memory)
    {

        require( pid_set.exists(uuid), "unable to create unique uuid try again later");
        Entities.PID memory pid = pid_db[uuid];

        return pid;
    }


    //DEMO
    function get_uuid_formated(bytes16 uuid)
    public 
    returns(bytes4 a,bytes2 b, bytes2 c, bytes2 d, bytes6 node)
    {
        Entities.PID memory p = get_pid(uuid);
        return Entities.parse(p);
    }

}