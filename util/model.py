
import os
import logging
from configparser import SectionProxy

from web3 import Web3
import solcx
from solcx.exceptions import SolcNotInstalled

from dark.gateway import DarkGateway

class DarkDeployer:
    
    def __init__(self, dark_gateway: DarkGateway):
        assert type(dark_gateway) == DarkGateway, "dark_gateway must be a DarkGateway object"
        # assert type(smart_contract_config) == SectionProxy, "smart_contract_config must be configparser.SectionProxy type"

        # assert dark_gateway.is_deployed_contract_loaded() == True, "dark_gateway must be loaded with deployed contracts"
        self.dark_gateway = dark_gateway
        # assert smart_contract_config.name == 'smartcontracts', "smart_contract_config should contain only the smartcontracts config Section"

        self.smart_contract_config = dark_gateway.get_blockchain_smartcontracts_config()

        self.solc_version = self.smart_contract_config['solc_version']
        try:
            logging.info("    Checking for solx {} compiler".format(self.solc_version))
            solcx.set_solc_version(self.solc_version)
        except SolcNotInstalled:
            logging.info("    Installing solx {} compiler".format(self.solc_version))
            solcx.install_solc(self.solc_version)
            logging.info("    solx {} compiler installed".format(self.solc_version))
    

    def compile_all(self,contracts,output_values=["abi",'bin',"bin-runtime"],):
        """
        """

        solcx.set_solc_version(self.solc_version)
        logging.info("    Compiling Smart Contracts")
        compiled =  solcx.compile_files(contracts,
                                        output_values=output_values,
                                        solc_version=self.solc_version,
                                        optimize=True
                                        )
        logging.info("    Smart Contracts compiled")

        return compiled


    def compile_contract(self,contract_name,contracts,output_values=["abi",'bin',"bin-runtime","evm"]):
        
        logging.info("> Compiling Contracts")
        compiled =  self.compile_all(contracts,
                                output_values=output_values,
                                solc_version=self.solc_version
                                )

        for k in compiled.keys():
            if k.endswith(str(os.sep + contract_name)):
                return compiled[k]
        
        raise Exception('This shouldnt happend')

    def deploy_contracts(self,compiled_contracts:dict):
        logging.info("> Deploying Contracts")
        config = self.dark_gateway.get_blockchain_config()

        # lista = config['smartcontracts']['lib_files'].split() +\
        lista = self.smart_contract_config['utils_files'].split() +\
                self.smart_contract_config['dbs_files'].split() +\
                self.smart_contract_config['service_files'].split()

        deployed_contract_dict = {}
        
        for contract_name in lista:
            if contract_name not in ['Entities.sol' , 'NoidProvider.sol']:
                for ci in compiled_contracts.keys():
                    #TODO IMPROVE THIS METHOD TO AVOID COLISION
                    if contract_name.split('.')[0] == ci.split(':')[-1]:
                        logging.info("    deploying : " + str(contract_name) + "..." )
                        deployed_contract_dict[str(contract_name)] = self.dark_gateway.deploy_contract_besu(
                                                                    compiled_contracts[ci],
                                                                    )
                
        logging.info("    deployed : " + str(len(lista)) + " contracts" )
        acc_balance = str(self.dark_gateway.get_account_balance())
        logging.info("    account initial balance : " + acc_balance )
        logging.info("")
        return deployed_contract_dict

