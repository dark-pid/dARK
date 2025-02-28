import pytest
import os
import json
import configparser
from unittest.mock import MagicMock, patch
import sys

# Add the project root to Python path for imports
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

@pytest.fixture
def test_config():
    """Create a test configuration."""
    config = configparser.ConfigParser()
    config['base'] = {
        'blockchain_net': 'test-net',
        'dapp_dir': 'dARK_dapp'
    }
    config['test-net'] = {
        'url': 'http://localhost:8545',
        'chain_id': '1337',
        'min_gas_price': '100',
        'account_priv_key': '0xae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f'
    }
    return config

@pytest.fixture
def deployed_contracts():
    """Load deployed contract addresses from deployment.json if it exists, otherwise use mocks."""
    deployment_file = os.path.join(os.path.dirname(__file__), '../deployment.json')
    
    if os.path.exists(deployment_file):
        with open(deployment_file, 'r') as f:
            return json.load(f)
    else:
        # Return mock addresses
        return {
            'NoidProvider': '0x1000000000000000000000000000000000000001',
            'PidDB': '0x1000000000000000000000000000000000000002',
            'UrlDB': '0x1000000000000000000000000000000000000003',
            'ExternalPidDB': '0x1000000000000000000000000000000000000004',
            'AuthoritiesDB': '0x1000000000000000000000000000000000000005',
            'UrlService': '0x1000000000000000000000000000000000000006',
            'ExternalPIDService': '0x1000000000000000000000000000000000000007',
            'AuthoritiesService': '0x1000000000000000000000000000000000000008',
            'PIDService': '0x1000000000000000000000000000000000000009',
            'TestAuthority': {
                'dnmaId': '0x0000000000000000000000000000000000000000000000000000000000000123',
                'providerAddr': '0x1000000000000000000000000000000000000010'
            }
        }

@pytest.fixture
def mock_web3():
    """Create a mock Web3 instance."""
    with patch('web3.Web3') as mock:
        mock_w3 = MagicMock()
        mock.HTTPProvider.return_value = MagicMock()
        mock.return_value = mock_w3
        
        # Setup eth module
        mock_w3.eth.chain_id = 1337
        mock_w3.eth.get_transaction_count.return_value = 0
        mock_w3.eth.gas_price = 20000000000
        mock_w3.eth.estimate_gas.return_value = 2000000
        
        # Setup account
        mock_w3.eth.account.from_key.return_value.address = "0x123456789abcdef"
        
        # Setup contract
        mock_contract = MagicMock()
        mock_w3.eth.contract.return_value = mock_contract
        
        yield mock

@pytest.fixture
def real_gateway(test_config, deployed_contracts):
    """Create a real DarkGateway instance for integration testing with a local node."""
    # Only import here to avoid circular imports
    from dark.gateway import DarkGateway
    
    # Check if local node is running
    import socket
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(1)
        result = sock.connect_ex(('localhost', 8545))
        sock.close()
        
        if result != 0:
            pytest.skip("Local Ethereum node not running on port 8545")
    except:
        pytest.skip("Could not check if local Ethereum node is running")
    
    # Create a configured gateway pointing to the local node
    gateway = DarkGateway(test_config)
    
    # Patch the contract loading to use the deployed contracts
    def mock_load_contracts(self):
        # Real implementation but use the deployed_contracts addresses
        pass
    
    with patch.object(DarkGateway, '_load_contracts', mock_load_contracts):
        return gateway