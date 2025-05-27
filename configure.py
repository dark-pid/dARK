import os
import inspect
import configparser
import logging
import ast

from util import DarkDeployer
from dark.gateway import DarkGateway
from dark import DarkMap

###
### VARIABLES
###

PROJECT_ROOT = os.path.dirname(os.path.realpath(__file__))

config_file_path = os.path.join(PROJECT_ROOT,'config.ini')
deployed_contracts_config_path = os.path.join(PROJECT_ROOT,'deployed_contracts.ini')
noid_provider_config_path = os.path.join(PROJECT_ROOT,'noid_provider_config.ini')

# LOAD CONFIGURATION
config = configparser.ConfigParser()
config.read(config_file_path)

#LOG SETUP 
logging.basicConfig(level=logging.INFO)

#DarkGateWay
dark_gw = DarkGateway(config)
#DarDeployer
dark_deployer = DarkDeployer(dark_gw)

#configure smart contracts
dark_deployer.setup_dark_onchain_contracts(deployed_contracts_config_path)
#configure payloadschema
# dark_deployer.configure_payload_schema(deployed_contracts_config_path,config_file_path)
#configure noid_provider
dark_deployer.configure_noid_provider(deployed_contracts_config_path,noid_provider_config_path)
