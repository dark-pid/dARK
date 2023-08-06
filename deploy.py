import os
import inspect
import configparser
import logging
import ast

from util import DarkDeployer
from dark.gateway import DarkGateway

###
### Class Methods
###

def get_contract(contract_name,contracts_dicts):
    contract_name = contract_name.split('.')[0]
    for k in contracts_dicts.keys():
        if k.endswith(':'+contract_name):
            return contracts_dicts[k]
    
    raise Exception('This shouldnt happend')

def populate_file_list(dir,files):
    """
        Private method to populate a list with full path of the smartcontrats
    """
    lista = []
    for i in files:
        lista.append( os.path.join(dir,i) )
    return lista

def save_smart_contract(deployed_contracts_dict,compiled_contracts_dict,deployed_contracts_config_path):
    """
        Save the deployed smart contracts
        - inputs the deploed_contracts dict

        - It is essential to configure the contract prior to its usage
        - Please only use this method to save configured contracts
    """
    logging.info("> Saving Deployed Smart Contracts config in : {}".format(deployed_contracts_config_path))
    config = configparser.ConfigParser()

    already_config_set = set()
    for deployed_sc_name in deployed_contracts_dict.keys():
        for compiled_sc_name in compiled_contracts_dict.keys():

            if deployed_sc_name.split('.')[0] == compiled_sc_name.split(':')[-1]:
            # if (dsc_name.endswith(csc_name.split('.')[0])) and (dsc_name not in already_config_set):
                addr = deployed_contracts_dict[deployed_sc_name]
                abi = compiled_contracts_dict[compiled_sc_name]['abi']
                # print(deployed_sc_name,addr,compiled_sc_name,abi)
                logging.info("\t Converting {} SmartContract".format(deployed_sc_name))
                config[deployed_sc_name] = {'addr' : addr, 'abi' : abi}

    with open(deployed_contracts_config_path, 'w') as configfile:
        config.write(configfile)
    logging.info(" SmartContract Loaded on Blockchain!")



###
### VARIABLES
###

PROJECT_ROOT = os.path.dirname(os.path.realpath(__file__))

config_file_path = os.path.join(PROJECT_ROOT,'config.ini')
deployed_contracts_config_path = os.path.join(PROJECT_ROOT,'deployed_contracts.ini')
# noid_provider_config_path = os.path.join(PROJECT_ROOT,'noid_provider_config.ini')


#LOG SETUP 
logging.basicConfig(level=logging.INFO)

# LOAD CONFIGURATION
config = configparser.ConfigParser()
config.read(config_file_path)

#PATH SETUP
DAPP_ROOT = os.path.join(PROJECT_ROOT, config['base']['dapp_dir'])
LIB_PATH = os.path.join(DAPP_ROOT, config['smartcontracts']['lib_dir'])
UTIL_PATH = os.path.join(DAPP_ROOT, config['smartcontracts']['util_dir'])
DB_PATH = os.path.join(DAPP_ROOT, config['smartcontracts']['db_dir'])
SERVICE_PATH = os.path.join(DAPP_ROOT, config['smartcontracts']['service_dir'])

#CONTRACTS 
libs_path = populate_file_list(LIB_PATH,config['smartcontracts']['lib_files'].split())
utils_path = populate_file_list(UTIL_PATH,config['smartcontracts']['utils_files'].split())
dbs_paths = populate_file_list(DB_PATH,config['smartcontracts']['dbs_files'].split())
services_path = populate_file_list(SERVICE_PATH,config['smartcontracts']['service_files'].split())


#DarkGateWay
dark_gw = DarkGateway(config)
#DarDeployer
dark_deployer = DarkDeployer(dark_gw)

# COMPILE CONTRACTS
compiled_contracts = dark_deployer.compile_all(services_path + dbs_paths + utils_path + libs_path)
# DEPLOY CONTRACTS
dc = dark_deployer.deploy_contracts(compiled_contracts)

# save smart contracts in a confi file
save_smart_contract(dc,compiled_contracts,deployed_contracts_config_path)