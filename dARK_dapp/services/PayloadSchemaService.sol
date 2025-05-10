// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

// import "../libs/openzeppelin/Ownable.sol";
import "../db/PayloadSchemaDB.sol";
import "../util/Entities.sol";

// contract PayloadSchemaService is Ownable {
contract PayloadSchemaService {
    address private db_addr;

    event STORE_PAYLOAD_SCHEMA(bytes32 id, string schema_name, string schema_version);

    constructor() {
        // The owner is set to the deployer of the contract
    }

    /**
     * @notice Set the PayloadSchemaDB address.
     * @param addr The address of the PayloadSchemaDB contract.
     * Only the owner can set this address.
     */
    
    function set_db(address addr) public { 
        // function set_db(address addr) public onlyOwner {
        db_addr = addr;
    }

    /**
     * @notice Create a new payload schema if it doesn't exist.
     * @param schema_name The name of the schema.
     * @param schema_version The version of the schema.
     * @param configured Whether the payload schema is configured or not.
     * @return schema_id The ID of the created or existing schema.
     */
    function get_or_create_payload_schema(string memory schema_name, 
                                            string memory schema_version, 
                                            bool configured)
        public returns (bytes32 schema_id)
    {
        PayloadSchemaDB db = PayloadSchemaDB(db_addr);
        
        try db.get(schema_name, schema_version) returns (SystemEntities.PayloadSchema memory existingSchema) {
             schema_id = db.gen_schema_id(existingSchema.schema_name, existingSchema.schema_version);
        } catch {
            // schema_id = db.save(schema_name, schema_version, configured);
            schema_id = db.save(schema_name, schema_version, configured);
            emit STORE_PAYLOAD_SCHEMA(schema_id, schema_name, schema_version);
        }
    }

    /**
     * @notice Retrieve a payload schema by its ID.
     * @param schema_id The ID of the schema to retrieve.
     * @return The payload schema associated with the given ID.
     */
    function get(bytes32 schema_id) 
    public view returns (SystemEntities.PayloadSchema memory) 
    {
        PayloadSchemaDB db = PayloadSchemaDB(db_addr);
        return db.get(schema_id);
    }

    /**
     * @notice Retrieve a payload schema by its name and version.
     * @param schema_name The name of the schema.
     * @param schema_version The version of the schema.
     * @return The payload schema associated with the given name and version.
     */
    function get(string memory schema_name, string memory schema_version) 
    public view returns (SystemEntities.PayloadSchema memory) 
    {
        PayloadSchemaDB db = PayloadSchemaDB(db_addr);
        return db.get(schema_name, schema_version);
    }

    /**
     * @notice Add a server to an existing payload schema.
     * @param schema_id The ID of the payload schema.
     * @param server_addr The address of the server to be added.
     */
    function add_server_to_schema(bytes32 schema_id, string memory server_addr) 
    public 
    {
        PayloadSchemaDB db = PayloadSchemaDB(db_addr);
        db.add_server_to_schema(schema_id, server_addr);
    }

    /**
     * @notice Set the status of an existing payload schema.
     * @param schema_id The ID of the schema to update.
     * @param configured The new status to set for the schema.
     */
    function set_schema_status(bytes32 schema_id, bool configured) 
    public 
    {
        PayloadSchemaDB db = PayloadSchemaDB(db_addr);
        db.set_schema_status(schema_id, configured);
    }
}
