# dARK Testing Framework

This document outlines a comprehensive testing framework for the dARK (Decentralized ARK) project covering all layers and functionalities.

## Testing Architecture

The testing framework follows a layered approach that matches the dARK system architecture:

1. **Unit Tests**: Test individual contract functionality in isolation
2. **Integration Tests**: Test interactions between contracts
3. **End-to-End Tests**: Test complete workflows from a user perspective
4. **Python Client Tests**: Test the Python client library that interacts with the dARK contracts

## Test Directory Structure

```
test/
├── contracts/           # Unit tests for individual contracts
│   ├── db/              # Database layer contract tests
│   ├── services/        # Service layer contract tests
│   └── util/            # Utility contract tests
├── integration/         # Integration tests between contracts
├── e2e/                 # End-to-end workflow tests
└── python/              # Python client library tests
```

## Testing Framework Components

### 1. Hardhat Environment

Hardhat provides a modern Ethereum development environment for testing Solidity contracts:

```javascript
// hardhat.config.js
module.exports = {
  solidity: "0.8.18",
  networks: {
    hardhat: {
      chainId: 1337
    },
    local: {
      url: "http://127.0.0.1:8545",
      chainId: 1337
    }
  },
  paths: {
    sources: "./dARK_dapp",
    tests: "./test",
    artifacts: "./artifacts"
  }
};
```

### 2. Unit Test Templates

#### Database Layer Tests

Example test for PidDB.sol:

```javascript
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("PidDB", function() {
  let pidDB;
  let owner, user1, user2;
  let noidProvider;

  beforeEach(async function() {
    [owner, user1, user2] = await ethers.getSigners();
    
    // Deploy NoidProvider mock
    const NoidProvider = await ethers.getContractFactory("NoidProvider");
    noidProvider = await NoidProvider.deploy();
    
    // Deploy PidDB
    const PidDB = await ethers.getContractFactory("PidDB");
    pidDB = await PidDB.deploy();
  });

  describe("assing_id", function() {
    it("should assign a new PID with the correct owner", async function() {
      const tx = await pidDB.assing_id(noidProvider.address);
      const receipt = await tx.wait();
      
      // Get PID hash from event
      const event = receipt.events.find(e => e.event === "ID");
      const pidHash = event.args.uuid;
      
      const pid = await pidDB.get(pidHash);
      expect(pid.owner).to.equal(owner.address);
    });
  });
  
  // Additional tests for other methods
});
```

#### Service Layer Tests

Example test for PIDService.sol:

```javascript
describe("PIDService", function() {
  let pidService, pidDB, urlService, externalPIDService, authoritiesService;
  let owner, user1;
  
  beforeEach(async function() {
    [owner, user1] = await ethers.getSigners();
    
    // Deploy dependent contracts
    const PidDB = await ethers.getContractFactory("PidDB");
    pidDB = await PidDB.deploy();
    
    const UrlService = await ethers.getContractFactory("UrlService");
    urlService = await UrlService.deploy();
    
    const ExternalPIDService = await ethers.getContractFactory("ExternalPIDService");
    externalPIDService = await ExternalPIDService.deploy();
    
    const AuthoritiesService = await ethers.getContractFactory("AuthoritiesService");
    authoritiesService = await AuthoritiesService.deploy();
    
    // Deploy PIDService
    const PIDService = await ethers.getContractFactory("PIDService");
    pidService = await PIDService.deploy();
    
    // Set dependencies
    await pidService.set_db(pidDB.address);
    await pidService.set_url_service(urlService.address);
    await pidService.set_externalpid_service(externalPIDService.address);
    await pidService.set_auth_service(authoritiesService.address);
  });
  
  describe("assingID", function() {
    it("should assign a new PID", async function() {
      // Setup mocked authority and provider
      // ... 
      
      const tx = await pidService.assingID(owner.address);
      const receipt = await tx.wait();
      
      // Verify events and state
      // ...
    });
  });
  
  // Additional tests
});
```

### 3. Integration Tests

Example integration test between PIDService and UrlService:

```javascript
describe("PIDService to UrlService Integration", function() {
  // Setup code similar to PIDService test
  
  it("should add a URL to a PID", async function() {
    // Create a PID first
    const tx1 = await pidService.assingID(owner.address);
    const receipt1 = await tx1.wait();
    const pidEvent = receipt1.events.find(e => e.event === "log_id");
    const pidHash = pidEvent.args.id;
    
    // Add URL to the PID
    const url = "https://example.com/resource";
    await pidService.add_externalLinks(pidHash, url);
    
    // Verify URL was properly added
    const pid = await pidDB.get(pidHash);
    // Additional verification
  });
});
```

### 4. End-to-End Tests

Example of a complete workflow:

```javascript
describe("Complete PID Creation Workflow", function() {
  // Setup code
  
  it("should create PID, add URL, and resolve it", async function() {
    // 1. Create a DNMA
    const dnmaId = await authoritiesService.create_dnam("example.org", "x", owner.address);
    
    // 2. Configure NOID provider for the DNMA
    await authoritiesService.configure_noid_provider_dnma("test", dnmaId, 8, 0);
    
    // 3. Create a PID
    const pidHash = await pidService.assingID(owner.address);
    
    // 4. Add a URL to the PID
    await pidService.add_externalLinks(pidHash, "https://example.org/resource");
    
    // 5. Add metadata payload
    await pidService.set_payload(pidHash, '{"title": "Test Resource"}');
    
    // 6. Add external PID mapping
    await pidService.addExternalPid(pidHash, "doi", "10.1234/test");
    
    // 7. Verify PID resolution works properly
    // Additional verification steps
  });
});
```

### 5. Python Client Tests

Example pytest for the Python client:

```python
import pytest
from dark.gateway import DarkGateway

def test_pid_creation(configured_gateway):
    # Test creating a PID through the Python client
    gateway = configured_gateway
    pid_hash = gateway.create_pid()
    
    # Verify PID was created
    pid = gateway.get_pid(pid_hash)
    assert pid is not None
    assert pid.owner == gateway.account

def test_complete_workflow(configured_gateway):
    # Test a complete workflow using the Python client
    gateway = configured_gateway
    
    # Create PID
    pid_hash = gateway.create_pid()
    
    # Add URL
    gateway.add_url(pid_hash, "https://example.org/resource")
    
    # Add metadata
    gateway.set_payload(pid_hash, title="Test Resource")
    
    # Verify
    pid = gateway.get_pid(pid_hash)
    assert pid.url == "https://example.org/resource"
    assert "title" in pid.payload
```

## Testing Fixtures and Utilities

### Hardhat Fixtures

```javascript
// test/fixtures.js
const { ethers } = require("hardhat");

async function deployDarkFixture() {
  const [owner, user1, user2] = await ethers.getSigners();
  
  // Deploy all contracts and set up dependencies
  
  // Return complete environment
  return {
    owner, user1, user2,
    pidDB, urlDB, externalPidDB, authoritiesDB,
    pidService, urlService, externalPIDService, authoritiesService,
    noidProvider
  };
}

module.exports = { deployDarkFixture };
```

### Python Pytest Fixtures

```python
# test/python/conftest.py
import pytest
from dark.gateway import DarkGateway

@pytest.fixture
def configured_gateway():
    # Load config
    config = load_test_config()
    
    # Create gateway
    gateway = DarkGateway(config)
    
    # Setup initial state
    # ...
    
    return gateway
```

## Test Coverage Goals

1. **Database Layer**: 100% function coverage
   - CRUD operations for all entities
   - Access control and permissions
   - Data integrity and validation

2. **Service Layer**: 100% function coverage
   - Business logic validation
   - Cross-contract interactions
   - Error handling

3. **End-to-End Workflows**: Cover all key user stories
   - PID creation
   - URL management
   - External PID mapping
   - Authority management
   - Payload management

4. **Security Testing**:
   - Access control verification
   - Owner validation
   - Authority validation
   - Input validation

## Test Execution

### Setup Local Environment

1. Start a local Ethereum node:
```bash
npx hardhat node
```

2. Deploy contracts:
```bash
npx hardhat run scripts/deploy.js --network localhost
```

3. Run contract tests:
```bash
npx hardhat test
```

4. Run Python tests:
```bash
python -m pytest test/python
```

## Continuous Integration

Integrate tests into CI/CD pipeline:

```yaml
# .github/workflows/test.yml
name: dARK Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Set up Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '14'
      
      - name: Install dependencies
        run: npm install
      
      - name: Run Hardhat tests
        run: npx hardhat test
      
      - name: Set up Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.10'
      
      - name: Install Python dependencies
        run: pip install -r requirements.txt
      
      - name: Run Python tests
        run: python -m pytest
```

## Test Reports and Monitoring

1. Generate test coverage reports:
```bash
npx hardhat coverage
```

2. Generate Python test coverage:
```bash
python -m pytest --cov=dark
```

This comprehensive testing framework ensures the dARK project is robust, reliable, and functions as expected across all layers.