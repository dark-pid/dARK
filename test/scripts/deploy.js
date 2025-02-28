// This script handles deployment of all dARK contracts for testing

const { ethers } = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // Deploy library contracts first
  console.log("\nDeploying libraries...");
  
  const HitchensUnorderedKeySet = await ethers.getContractFactory("HitchensUnorderedKeySetLib");
  const hitchensUnorderedKeySet = await HitchensUnorderedKeySet.deploy();
  await hitchensUnorderedKeySet.deployed();
  console.log("HitchensUnorderedKeySetLib deployed to:", hitchensUnorderedKeySet.address);
  
  // Link the library to the contracts that use it
  const linkLibraries = {
    libraries: {
      "HitchensUnorderedKeySetLib": hitchensUnorderedKeySet.address
    }
  };
  
  // Deploy utility contracts
  console.log("\nDeploying utility contracts...");
  
  const NoidProvider = await ethers.getContractFactory("NoidProvider");
  const noidProvider = await NoidProvider.deploy();
  await noidProvider.deployed();
  console.log("NoidProvider deployed to:", noidProvider.address);
  
  // Deploy DB contracts
  console.log("\nDeploying DB contracts...");
  
  const PidDB = await ethers.getContractFactory("PidDB", linkLibraries);
  const pidDB = await PidDB.deploy();
  await pidDB.deployed();
  console.log("PidDB deployed to:", pidDB.address);
  
  const UrlDB = await ethers.getContractFactory("UrlDB", linkLibraries);
  const urlDB = await UrlDB.deploy();
  await urlDB.deployed();
  console.log("UrlDB deployed to:", urlDB.address);
  
  const ExternalPidDB = await ethers.getContractFactory("ExternalPidDB", linkLibraries);
  const externalPidDB = await ExternalPidDB.deploy();
  await externalPidDB.deployed();
  console.log("ExternalPidDB deployed to:", externalPidDB.address);
  
  const AuthoritiesDB = await ethers.getContractFactory("AuthoritiesDB", linkLibraries);
  const authoritiesDB = await AuthoritiesDB.deploy();
  await authoritiesDB.deployed();
  console.log("AuthoritiesDB deployed to:", authoritiesDB.address);
  
  // Deploy service contracts
  console.log("\nDeploying service contracts...");
  
  const UrlService = await ethers.getContractFactory("UrlService");
  const urlService = await UrlService.deploy();
  await urlService.deployed();
  console.log("UrlService deployed to:", urlService.address);
  
  const ExternalPIDService = await ethers.getContractFactory("ExternalPIDService");
  const externalPIDService = await ExternalPIDService.deploy();
  await externalPIDService.deployed();
  console.log("ExternalPIDService deployed to:", externalPIDService.address);
  
  const AuthoritiesService = await ethers.getContractFactory("AuthoritiesService");
  const authoritiesService = await AuthoritiesService.deploy();
  await authoritiesService.deployed();
  console.log("AuthoritiesService deployed to:", authoritiesService.address);
  
  const PIDService = await ethers.getContractFactory("PIDService");
  const pidService = await PIDService.deploy();
  await pidService.deployed();
  console.log("PIDService deployed to:", pidService.address);
  
  // Configure contracts
  console.log("\nConfiguring contracts...");
  
  // Set DB addresses in services
  await urlService.set_db(urlDB.address);
  await externalPIDService.set_db(externalPidDB.address);
  await authoritiesService.set_db(authoritiesDB.address);
  
  // Set dependencies in PIDService
  await pidService.set_db(pidDB.address);
  await pidService.set_url_service(urlService.address);
  await pidService.set_externalpid_service(externalPIDService.address);
  await pidService.set_auth_service(authoritiesService.address);
  
  console.log("Contract configuration complete");
  
  // Create a test authority
  console.log("\nCreating test authority...");
  
  const tx1 = await authoritiesService.create_dnam("test.org", "t", deployer.address);
  const receipt1 = await tx1.wait();
  const event1 = receipt1.events.find(e => e.event === "log_id");
  const dnmaId = event1.args.id;
  
  console.log("Created test DNMA with ID:", dnmaId);
  
  // Configure NOID provider for the authority
  const tx2 = await authoritiesService.configure_noid_provider_dnma("test", dnmaId, 8, 0);
  const receipt2 = await tx2.wait();
  const event2 = receipt2.events.find(e => e.event === "log_addr");
  const providerAddr = event2.args.id;
  
  console.log("Configured NOID provider at address:", providerAddr);
  
  // Save deployed contract addresses to file
  const deployments = {
    NoidProvider: noidProvider.address,
    PidDB: pidDB.address,
    UrlDB: urlDB.address,
    ExternalPidDB: externalPidDB.address,
    AuthoritiesDB: authoritiesDB.address,
    UrlService: urlService.address,
    ExternalPIDService: externalPIDService.address,
    AuthoritiesService: authoritiesService.address,
    PIDService: pidService.address,
    TestAuthority: {
      dnmaId: dnmaId,
      providerAddr: providerAddr
    }
  };
  
  fs.writeFileSync(
    path.join(__dirname, '../deployment.json'),
    JSON.stringify(deployments, null, 2)
  );
  
  console.log("\nDeployment complete. Contract addresses saved to deployment.json");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });