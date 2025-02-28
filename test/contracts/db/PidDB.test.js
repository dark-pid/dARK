const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PidDB Contract", function() {
  let pidDB;
  let owner, user1, user2;
  let noidProvider;

  beforeEach(async function() {
    [owner, user1, user2] = await ethers.getSigners();
    
    // Deploy mock NoidProvider first
    const NoidProvider = await ethers.getContractFactory("NoidProvider");
    noidProvider = await NoidProvider.deploy();
    await noidProvider.deployed();
    
    // Deploy PidDB
    const PidDB = await ethers.getContractFactory("PidDB");
    pidDB = await PidDB.deploy();
    await pidDB.deployed();
  });

  describe("Core functionality", function() {
    it("should assign a new PID with the correct owner", async function() {
      const tx = await pidDB.assing_id(noidProvider.address);
      const receipt = await tx.wait();
      
      // Get PID hash from event
      const event = receipt.events.find(e => e.event === "ID");
      const pidHash = event.args.pid_hash;
      
      const pid = await pidDB.get(pidHash);
      expect(pid.owner).to.equal(owner.address);
      expect(pid.pid_hash).to.equal(pidHash);
    });
    
    it("should fail to retrieve a non-existent PID", async function() {
      const nonExistentHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("nonexistent"));
      await expect(pidDB.get(nonExistentHash)).to.be.revertedWith("uuid does not exists");
    });
    
    it("should count PIDs correctly", async function() {
      expect(await pidDB.count()).to.equal(0);
      
      await pidDB.assing_id(noidProvider.address);
      expect(await pidDB.count()).to.equal(1);
      
      await pidDB.assing_id(noidProvider.address);
      expect(await pidDB.count()).to.equal(2);
    });
    
    it("should retrieve a PID by index", async function() {
      await pidDB.assing_id(noidProvider.address);
      const key = await pidDB.get_by_index(0);
      expect(key).to.not.equal(ethers.constants.HashZero);
      
      const pid = await pidDB.get(key);
      expect(pid.pid_hash).to.equal(key);
    });
  });

  describe("External PID management", function() {
    let pidHash;
    
    beforeEach(async function() {
      const tx = await pidDB.assing_id(noidProvider.address);
      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "ID");
      pidHash = event.args.pid_hash;
    });
    
    it("should add an external PID to a PID", async function() {
      const externalPidId = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("external-pid"));
      await pidDB.add_externalPid(pidHash, externalPidId);
      
      const pid = await pidDB.get(pidHash);
      expect(pid.externalPIDs.length).to.equal(1);
      expect(pid.externalPIDs[0]).to.equal(externalPidId);
    });
  });

  describe("URL management", function() {
    let pidHash;
    
    beforeEach(async function() {
      const tx = await pidDB.assing_id(noidProvider.address);
      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "ID");
      pidHash = event.args.pid_hash;
    });
    
    it("should add a URL to a PID", async function() {
      const urlId = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("https://example.com"));
      await pidDB.add_url(pidHash, urlId);
      
      const pid = await pidDB.get(pidHash);
      expect(pid.url).to.equal(urlId);
    });
  });

  describe("Payload schema management", function() {
    it("should create a payload schema", async function() {
      const schemaName = "TEST_SCHEMA";
      const schemaId = await pidDB.save_payload_schema(schemaName);
      
      const schema = await pidDB.get_payload_schema(schemaName);
      expect(schema.schema_name).to.equal(schemaName);
      expect(schema.configured).to.equal(false);
    });
    
    it("should add attributes to a schema", async function() {
      const schemaName = "TEST_SCHEMA";
      await pidDB.save_payload_schema(schemaName);
      
      await pidDB.add_attribute_to_schema(schemaName, "TITLE");
      await pidDB.add_attribute_to_schema(schemaName, "AUTHOR");
      
      const schema = await pidDB.get_payload_schema(schemaName);
      expect(schema.attribute_list.length).to.equal(2);
      expect(schema.attribute_list[0]).to.equal("TITLE");
      expect(schema.attribute_list[1]).to.equal("AUTHOR");
    });
    
    it("should mark a schema as configured", async function() {
      const schemaName = "TEST_SCHEMA";
      await pidDB.save_payload_schema(schemaName);
      await pidDB.add_attribute_to_schema(schemaName, "TITLE");
      
      await pidDB.mark_schema_as_configured(schemaName);
      
      const schema = await pidDB.get_payload_schema(schemaName);
      expect(schema.configured).to.equal(true);
    });
    
    it("should fail to add attributes to a configured schema", async function() {
      const schemaName = "TEST_SCHEMA";
      await pidDB.save_payload_schema(schemaName);
      await pidDB.mark_schema_as_configured(schemaName);
      
      await expect(
        pidDB.add_attribute_to_schema(schemaName, "TITLE")
      ).to.be.revertedWith("Schema marked as configured");
    });
  });

  describe("Payload management", function() {
    let pidHash;
    
    beforeEach(async function() {
      const tx = await pidDB.assing_id(noidProvider.address);
      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "ID");
      pidHash = event.args.pid_hash;
      
      // Create schema and attributes
      await pidDB.save_payload_schema("TEST_SCHEMA");
      await pidDB.add_attribute_to_schema("TEST_SCHEMA", "TITLE");
      await pidDB.add_attribute_to_schema("TEST_SCHEMA", "AUTHOR");
      await pidDB.mark_schema_as_configured("TEST_SCHEMA");
    });
    
    it("should store payload data", async function() {
      await pidDB.store_payload(pidHash, "TEST_SCHEMA", "TITLE", "Test Title");
      await pidDB.store_payload(pidHash, "TEST_SCHEMA", "AUTHOR", "Test Author");
      
      const payload = await pidDB.get_payload(pidHash);
      expect(payload.attributes_values[0]).to.equal("Test Title");
      expect(payload.attributes_values[1]).to.equal("Test Author");
    });
    
    it("should fail to store payload for non-existent attribute", async function() {
      await expect(
        pidDB.store_payload(pidHash, "TEST_SCHEMA", "NONEXISTENT", "Value")
      ).to.be.revertedWith("Attribute does not exist in Schema");
    });
    
    it("should link payload to PID", async function() {
      await pidDB.store_payload(pidHash, "TEST_SCHEMA", "TITLE", "Test Title");
      await pidDB.set_payload_in_pid(pidHash, pidHash);
      
      const pid = await pidDB.get(pidHash);
      expect(pid.payload).to.equal(pidHash);
    });
  });
});