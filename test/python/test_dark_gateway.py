import pytest
import os
import configparser
from unittest.mock import MagicMock, patch
import sys

# Add the project root to Python path for imports
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '../..')))

from dark.gateway import DarkGateway

class TestDarkGateway:
    """Tests for the DarkGateway class that interacts with the dARK contracts."""
    
    @pytest.fixture
    def mock_config(self):
        """Create a mock configuration for testing."""
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
    def mock_contract_config(self):
        """Create a mock deployed contracts configuration."""
        config = configparser.ConfigParser()
        config['PidDB.sol'] = {
            'addr': '0xb9A219631Aed55eBC3D998f17C3840B7eC39C0cc',
            'abi': '{"abi": []}'
        }
        config['PIDService.sol'] = {
            'addr': '0xC8c03647d39a96f02f6Ce8999bc22493C290e734',
            'abi': '{"abi": []}'
        }
        return config
    
    @pytest.fixture
    def gateway(self, mock_config, mock_contract_config, monkeypatch):
        """Create a DarkGateway instance with mocked dependencies."""
        # Mock Web3 and contract interactions
        with patch('dark.gateway.Web3') as mock_web3, \
             patch('dark.gateway.Account') as mock_account, \
             patch('builtins.open'), \
             patch('configparser.ConfigParser.read'):
            
            # Setup mock Web3 provider
            mock_provider = MagicMock()
            mock_web3.HTTPProvider.return_value = mock_provider
            mock_web3.return_value.eth.chain_id = 1337
            mock_web3.return_value.eth.get_transaction_count.return_value = 0
            
            # Setup mock account
            mock_account.from_key.return_value.address = "0x123456789abcdef"
            
            # Setup mock contract instance
            mock_contract = MagicMock()
            mock_web3.return_value.eth.contract.return_value = mock_contract
            
            # Mock configparser.read to return our mock configs
            monkeypatch.setattr('configparser.ConfigParser.read', lambda self, files: None)
            
            # Create gateway instance
            gateway = DarkGateway(mock_config)
            
            # Mock contract loading
            gateway._load_contracts = MagicMock()
            gateway.contracts = {
                'PidDB.sol': mock_contract,
                'PIDService.sol': mock_contract,
                'UrlService.sol': mock_contract,
                'ExternalPIDService.sol': mock_contract,
                'AuthoritiesService.sol': mock_contract
            }
            
            return gateway
    
    def test_init(self, gateway):
        """Test gateway initialization."""
        assert gateway is not None
        assert gateway.w3 is not None
        assert gateway.account is not None
    
    def test_create_pid(self, gateway):
        """Test PID creation through the gateway."""
        # Setup mock for PIDService.assingID
        mock_tx_receipt = MagicMock()
        mock_tx_receipt.blockNumber = 1
        mock_log = {'args': {'id': b'1234567890abcdef'}}
        mock_tx_receipt.logs = [mock_log]
        
        gateway.contracts['PIDService.sol'].functions.assingID.return_value.call.return_value = b'1234567890abcdef'
        gateway.contracts['PIDService.sol'].functions.assingID.return_value.transact.return_value = b'tx_hash'
        gateway.w3.eth.wait_for_transaction_receipt.return_value = mock_tx_receipt
        gateway.w3.eth.contract.return_value.events.log_id.return_value.process_receipt.return_value = [mock_log]
        
        # Call create_pid
        pid_hash = gateway.create_pid()
        
        # Verify
        assert pid_hash == b'1234567890abcdef'
        gateway.contracts['PIDService.sol'].functions.assingID.assert_called_once()
    
    def test_add_url(self, gateway):
        """Test adding a URL to a PID."""
        pid_hash = b'1234567890abcdef'
        url = "https://example.com/resource"
        
        gateway.contracts['PIDService.sol'].functions.add_externalLinks.return_value.call.return_value = None
        gateway.contracts['PIDService.sol'].functions.add_externalLinks.return_value.transact.return_value = b'tx_hash'
        
        # Call add_url
        gateway.add_url(pid_hash, url)
        
        # Verify
        gateway.contracts['PIDService.sol'].functions.add_externalLinks.assert_called_with(pid_hash, url)
    
    def test_add_external_pid(self, gateway):
        """Test adding an external PID mapping."""
        pid_hash = b'1234567890abcdef'
        schema = "doi"
        external_pid = "10.1234/test"
        
        gateway.contracts['PIDService.sol'].functions.addExternalPid.return_value.call.return_value = None
        gateway.contracts['PIDService.sol'].functions.addExternalPid.return_value.transact.return_value = b'tx_hash'
        
        # Call add_external_pid
        gateway.add_external_pid(pid_hash, schema, external_pid)
        
        # Verify
        gateway.contracts['PIDService.sol'].functions.addExternalPid.assert_called_with(pid_hash, schema, external_pid)
    
    def test_set_payload(self, gateway):
        """Test setting payload for a PID."""
        pid_hash = b'1234567890abcdef'
        payload = '{"title": "Test Resource", "author": "John Doe"}'
        
        gateway.contracts['PIDService.sol'].functions.set_payload.return_value.call.return_value = None
        gateway.contracts['PIDService.sol'].functions.set_payload.return_value.transact.return_value = b'tx_hash'
        
        # Call set_payload
        gateway.set_payload(pid_hash, payload)
        
        # Verify
        gateway.contracts['PIDService.sol'].functions.set_payload.assert_called_with(pid_hash, payload)
    
    def test_get_pid(self, gateway):
        """Test retrieving a PID."""
        pid_hash = b'1234567890abcdef'
        
        # Mock PID data returned from contract
        mock_pid = {
            'pid_hash': pid_hash,
            'noid': 'test-noid',
            'externalPIDs': [],
            'url': b'url-id',
            'payload': b'payload-id',
            'owner': '0x123456789abcdef'
        }
        
        gateway.contracts['PidDB.sol'].functions.get.return_value.call.return_value = mock_pid
        
        # Call get_pid
        pid = gateway.get_pid(pid_hash)
        
        # Verify
        assert pid == mock_pid
        gateway.contracts['PidDB.sol'].functions.get.assert_called_with(pid_hash)
    
    def test_create_authority(self, gateway):
        """Test creating a new authority."""
        name = "example.org"
        shoulder = "x"
        
        # Mock event logs
        mock_tx_receipt = MagicMock()
        mock_tx_receipt.blockNumber = 1
        mock_log = {'args': {'id': b'auth-id'}}
        mock_tx_receipt.logs = [mock_log]
        
        gateway.contracts['AuthoritiesService.sol'].functions.create_dnam.return_value.call.return_value = b'auth-id'
        gateway.contracts['AuthoritiesService.sol'].functions.create_dnam.return_value.transact.return_value = b'tx_hash'
        gateway.w3.eth.wait_for_transaction_receipt.return_value = mock_tx_receipt
        gateway.w3.eth.contract.return_value.events.log_id.return_value.process_receipt.return_value = [mock_log]
        
        # Call create_authority
        auth_id = gateway.create_authority(name, shoulder)
        
        # Verify
        assert auth_id == b'auth-id'
        gateway.contracts['AuthoritiesService.sol'].functions.create_dnam.assert_called_with(
            name, shoulder, gateway.account.address)
    
    def test_configure_noid_provider(self, gateway):
        """Test configuring a NOID provider for an authority."""
        auth_id = b'auth-id'
        name = "test"
        noid_len = 8
        
        # Mock event logs
        mock_tx_receipt = MagicMock()
        mock_tx_receipt.blockNumber = 1
        mock_log = {'args': {'id': '0xnoidprovider'}}
        mock_tx_receipt.logs = [mock_log]
        
        gateway.contracts['AuthoritiesService.sol'].functions.configure_noid_provider_dnma.return_value.call.return_value = '0xnoidprovider'
        gateway.contracts['AuthoritiesService.sol'].functions.configure_noid_provider_dnma.return_value.transact.return_value = b'tx_hash'
        gateway.w3.eth.wait_for_transaction_receipt.return_value = mock_tx_receipt
        gateway.w3.eth.contract.return_value.events.log_addr.return_value.process_receipt.return_value = [mock_log]
        
        # Call configure_noid_provider
        provider_addr = gateway.configure_noid_provider(auth_id, name, noid_len)
        
        # Verify
        assert provider_addr == '0xnoidprovider'
        gateway.contracts['AuthoritiesService.sol'].functions.configure_noid_provider_dnma.assert_called_with(
            name, auth_id, noid_len, 0)
    
    def test_end_to_end_workflow(self, gateway):
        """Test a complete end-to-end workflow."""
        # Mock all the necessary contract calls
        
        # 1. Create authority
        mock_auth_tx_receipt = MagicMock()
        mock_auth_tx_receipt.blockNumber = 1
        mock_auth_log = {'args': {'id': b'auth-id'}}
        mock_auth_tx_receipt.logs = [mock_auth_log]
        
        gateway.contracts['AuthoritiesService.sol'].functions.create_dnam.return_value.call.return_value = b'auth-id'
        gateway.contracts['AuthoritiesService.sol'].functions.create_dnam.return_value.transact.return_value = b'auth_tx_hash'
        
        # 2. Configure NOID provider
        mock_provider_tx_receipt = MagicMock()
        mock_provider_tx_receipt.blockNumber = 2
        mock_provider_log = {'args': {'id': '0xnoidprovider'}}
        mock_provider_tx_receipt.logs = [mock_provider_log]
        
        gateway.contracts['AuthoritiesService.sol'].functions.configure_noid_provider_dnma.return_value.call.return_value = '0xnoidprovider'
        gateway.contracts['AuthoritiesService.sol'].functions.configure_noid_provider_dnma.return_value.transact.return_value = b'provider_tx_hash'
        
        # 3. Create PID
        mock_pid_tx_receipt = MagicMock()
        mock_pid_tx_receipt.blockNumber = 3
        mock_pid_log = {'args': {'id': b'pid-id'}}
        mock_pid_tx_receipt.logs = [mock_pid_log]
        
        gateway.contracts['PIDService.sol'].functions.assingID.return_value.call.return_value = b'pid-id'
        gateway.contracts['PIDService.sol'].functions.assingID.return_value.transact.return_value = b'pid_tx_hash'
        
        # Mock wait_for_transaction_receipt to return different receipts based on tx hash
        def mock_wait_for_receipt(tx_hash):
            if tx_hash == b'auth_tx_hash':
                return mock_auth_tx_receipt
            elif tx_hash == b'provider_tx_hash':
                return mock_provider_tx_receipt
            elif tx_hash == b'pid_tx_hash':
                return mock_pid_tx_receipt
            return MagicMock()
        
        gateway.w3.eth.wait_for_transaction_receipt.side_effect = mock_wait_for_receipt
        
        # Mock event processing
        def mock_process_receipt(receipt, events):
            if receipt == mock_auth_tx_receipt:
                return [mock_auth_log]
            elif receipt == mock_provider_tx_receipt:
                return [mock_provider_log]
            elif receipt == mock_pid_tx_receipt:
                return [mock_pid_log]
            return []
        
        gateway.w3.eth.contract.return_value.events.log_id.return_value.process_receipt.side_effect = mock_process_receipt
        gateway.w3.eth.contract.return_value.events.log_addr.return_value.process_receipt.side_effect = mock_process_receipt
        
        # Perform end-to-end workflow
        # 1. Create authority
        auth_id = gateway.create_authority("example.org", "x")
        assert auth_id == b'auth-id'
        
        # 2. Configure NOID provider
        provider_addr = gateway.configure_noid_provider(auth_id, "test", 8)
        assert provider_addr == '0xnoidprovider'
        
        # 3. Create PID
        pid_hash = gateway.create_pid()
        assert pid_hash == b'pid-id'
        
        # 4. Add URL (no return value to assert)
        gateway.add_url(pid_hash, "https://example.com/resource")
        
        # 5. Add payload (no return value to assert)
        gateway.set_payload(pid_hash, '{"title": "Test Resource"}')
        
        # 6. Add external PID (no return value to assert)
        gateway.add_external_pid(pid_hash, "doi", "10.1234/test")
        
        # Verify all expected contract calls were made
        gateway.contracts['AuthoritiesService.sol'].functions.create_dnam.assert_called_once()
        gateway.contracts['AuthoritiesService.sol'].functions.configure_noid_provider_dnma.assert_called_once()
        gateway.contracts['PIDService.sol'].functions.assingID.assert_called_once()
        gateway.contracts['PIDService.sol'].functions.add_externalLinks.assert_called_once()
        gateway.contracts['PIDService.sol'].functions.set_payload.assert_called_once()
        gateway.contracts['PIDService.sol'].functions.addExternalPid.assert_called_once()