const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PIDService Contract", function() {
  let pidService;
  let pidDB;
  let urlService;
  let urlDB;
  let externalPIDService;
  let externalPidDB;
  let authoritiesService;
  let authoritiesDB;
  let noidProvider;
  
  let owner, user1, user2;
  
  beforeEach(async function() {
    [owner, user1, user2] = await ethers.getSigners();
    
    // Deploy all the dependent contracts first
    
    // 1. Deploy NoidProvider
    const NoidProvider = await ethers.getContractFactory("NoidProvider");
    noidProvider = await NoidProvider.deploy();
    await noidProvider.deployed();
    
    // 2. Deploy DB contracts
    const PidDB = await ethers.getContractFactory("PidDB");
    pidDB = await PidDB.deploy();
    await pidDB.deployed();
    
    const UrlDB = await ethers.getContractFactory("UrlDB");
    urlDB = await UrlDB.deploy();
    await urlDB.deployed();
    
    const ExternalPidDB = await ethers.getContractFactory("ExternalPidDB");
    externalPidDB = await ExternalPidDB.deploy();
    await externalPidDB.deployed();
    
    const AuthoritiesDB = await ethers.getContractFactory("AuthoritiesDB");
    authoritiesDB = await AuthoritiesDB.deploy();
    await authoritiesDB.deployed();
    
    // 3. Deploy service contracts
    const UrlService = await ethers.getContractFactory("UrlService");
    urlService = await UrlService.deploy();
    await urlService.deployed();
    await urlService.set_db(urlDB.address);
    
    const ExternalPIDService = await ethers.getContractFactory("ExternalPIDService");
    externalPIDService = await ExternalPIDService.deploy();
    await externalPIDService.deployed();
    await externalPIDService.set_db(externalPidDB.address);
    
    const AuthoritiesService = await ethers.getContractFactory("AuthoritiesService");
    authoritiesService = await AuthoritiesService.deploy();
    await authoritiesService.deployed();
    await authoritiesService.set_db(authoritiesDB.address);
    
    // 4. Deploy PIDService and set dependencies
    const PIDService = await ethers.getContractFactory("PIDService");
    pidService = await PIDService.deploy();
    await pidService.deployed();
    
    await pidService.set_db(pidDB.address);
    await pidService.set_url_service(urlService.address);
    await pidService.set_externalpid_service(externalPIDService.address);
    await pidService.set_auth_service(authoritiesService.address);
    
    // 5. Create a test authority and configure it
    const tx1 = await authoritiesService.create_dnam("example.org", "x", owner.address);
    const receipt1 = await tx1.wait();
    const event1 = receipt1.events.find(e => e.event === "log_id");
    const dnmaId = event1.args.id;
    
    const tx2 = await authoritiesService.configure_noid_provider_dnma("test", dnmaId, 8, 0);
    const receipt2 = await tx2.wait();
    const event2 = receipt2.events.find(e => e.event === "log_addr");
    const providerAddr = event2.args.id;
    
    // Store the provider address for owner
    await authoritiesDB.save_responsable(dnmaId, owner.address);
  });
  
  describe("PID Creation", function() {
    it("should assign a new PID", async function() {
      const tx = await pidService.assingID(owner.address);
      const receipt = await tx.wait();
      
      // Get PID hash from event
      const event = receipt.events.find(e => e.event === "log_id");
      const pidHash = event.args.id;
      
      // Verify PID was created
      const pid = await pidDB.get(pidHash);
      expect(pid.owner).to.equal(owner.address);
    });
    
    it("should reject PID creation for unauthorized users", async function() {
      // The user doesn't have authority, so this should fail
      await expect(
        pidService.connect(user1).assingID(user1.address)
      ).to.be.reverted;
    });
  });
  
  describe("URL Management", function() {
    let pidHash;
    
    beforeEach(async function() {
      const tx = await pidService.assingID(owner.address);
      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "log_id");
      pidHash = event.args.id;
    });
    
    it("should add a URL to a PID", async function() {
      const url = "https://example.com/resource";
      await pidService.add_externalLinks(pidHash, url);
      
      // Verify URL was added
      const pid = await pidDB.get(pidHash);
      expect(pid.url).to.not.equal(ethers.constants.HashZero);
    });
    
    it("should fail to add URL to non-existent PID", async function() {
      const nonExistentHash = ethers.utils.keccak256(ethers.utils.toUtf8Bytes("nonexistent"));
      await expect(
        pidService.add_externalLinks(nonExistentHash, "https://example.com")
      ).to.be.reverted;
    });
  });
  
  describe("External PID Management", function() {
    let pidHash;
    
    beforeEach(async function() {
      const tx = await pidService.assingID(owner.address);
      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "log_id");
      pidHash = event.args.id;
      
      // Add URL to make it valid (non-draft)
      await pidService.add_externalLinks(pidHash, "https://example.com/resource");
    });
    
    it("should add an external PID to a valid PID", async function() {
      const schema = "doi";
      const externalPid = "10.1234/test";
      await pidService.addExternalPid(pidHash, schema, externalPid);
      
      // Verify external PID was added
      const pid = await pidDB.get(pidHash);
      expect(pid.externalPIDs.length).to.be.at.least(1);
    });
    
    it("should fail to add external PID to a non-valid (draft) PID", async function() {
      // Create a new PID without URL (draft)
      const tx = await pidService.assingID(owner.address);
      const receipt = await tx.wait();
      const draftPidHash = receipt.events.find(e => e.event === "log_id").args.id;
      
      // Try to add external PID to draft PID
      await expect(
        pidService.addExternalPid(draftPidHash, "doi", "10.1234/test")
      ).to.be.revertedWith("This PID is a draft");
    });
  });
  
  describe("Payload Management", function() {
    let pidHash;
    
    beforeEach(async function() {
      // 1. Create PID
      const tx = await pidService.assingID(owner.address);
      const receipt = await tx.wait();
      const event = receipt.events.find(e => e.event === "log_id");
      pidHash = event.args.id;
      
      // 2. Add URL to make it valid
      await pidService.add_externalLinks(pidHash, "https://example.com/resource");
      
      // 3. Set up payload schema
      await pidService.create_payload_schema("TEST_SCHEMA");
      await pidService.add_attribute_payload_schema("TEST_SCHEMA", "TITLE");
      await pidService.add_attribute_payload_schema("TEST_SCHEMA", "AUTHOR");
      await pidService.mark_payload_schema_ready("TEST_SCHEMA");
    });
    
    it("should set payload for a valid PID", async function() {
      await pidService.set_payload_tmp(pidHash, "TEST_SCHEMA", "TITLE", "Test Title");
      await pidService.set_payload_tmp(pidHash, "TEST_SCHEMA", "AUTHOR", "Test Author");
      
      // Verify payload was set
      const pid = await pidDB.get(pidHash);
      expect(pid.payload).to.equal(pidHash);
    });
  });
  
  describe("End-to-End Flow", function() {
    it("should support a complete PID creation and management workflow", async function() {
      // 1. Create PID
      const tx1 = await pidService.assingID(owner.address);
      const receipt1 = await tx1.wait();
      const pidHash = receipt1.events.find(e => e.event === "log_id").args.id;
      
      // 2. Add URL
      const url = "https://example.com/resource";
      await pidService.add_externalLinks(pidHash, url);
      
      // 3. Create and configure payload schema
      await pidService.create_payload_schema("RESOURCE_SCHEMA");
      await pidService.add_attribute_payload_schema("RESOURCE_SCHEMA", "TITLE");
      await pidService.add_attribute_payload_schema("RESOURCE_SCHEMA", "AUTHOR");
      await pidService.mark_payload_schema_ready("RESOURCE_SCHEMA");
      
      // 4. Set payload
      await pidService.set_payload_tmp(pidHash, "RESOURCE_SCHEMA", "TITLE", "Test Resource");
      await pidService.set_payload_tmp(pidHash, "RESOURCE_SCHEMA", "AUTHOR", "John Doe");
      
      // 5. Add external PID mapping
      await pidService.addExternalPid(pidHash, "doi", "10.1234/test-resource");
      
      // 6. Verify everything was set correctly
      const pid = await pidDB.get(pidHash);
      expect(pid.owner).to.equal(owner.address);
      expect(pid.url).to.not.equal(ethers.constants.HashZero);
      expect(pid.externalPIDs.length).to.be.at.least(1);
      expect(pid.payload).to.equal(pidHash);
    });
  });
});