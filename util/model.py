
import os
import logging
import ast
from configparser import SectionProxy, ConfigParser

from web3 import Web3
import solcx
from solcx.exceptions import SolcNotInstalled

from dark.gateway import DarkGateway
from dark.util import invoke_contract_sync

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
        logging.info("> Compiling Smart Contracts")
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
    
    ###
    ### config method
    ###

    def setup_dark_onchain_contracts(self,deployed_contracts_config_path):

        logging.info("> Configure Onchain contracts...")
        smart_contract_config = ConfigParser()
        smart_contract_config.read(deployed_contracts_config_path)

        configured_contracts = {}
        initial_acc_balance = self.dark_gateway.get_account_balance()
        logging.info("    account initial balance : " + str(initial_acc_balance) )
        logging.info("    Configuring AuthoritiesService:")

        ##
        ## Authorities Service
        ##
        auth_db_addr = smart_contract_config['AuthoritiesDB.sol']['addr']
        contract_addr = smart_contract_config['AuthoritiesService.sol']['addr']
        contract_interface = smart_contract_config['AuthoritiesService.sol']['abi']
        # print(contract_addr,contract_interface)
        auth_service = self.dark_gateway.w3.eth.contract(address=contract_addr, abi=ast.literal_eval(contract_interface))
        sign_tx = self.dark_gateway.signTransaction(auth_service,'set_db' ,(auth_db_addr))
        receipt, tx_hash = invoke_contract_sync(self.dark_gateway,sign_tx)
        #TODO CHECK receipt['status'] == 1

        logging.info("        - db configured")
        logging.info("        - AuthoritiesService configured")
        configured_contracts['AuthoritiesService'] = auth_service

        ##
        ## pid db
        ##
        logging.info("    Configuring dARK PiD Database:")
        # uuid_provider_addr = deployed_contract_dict['UUIDProvider.sol'][0]
        contract_addr = smart_contract_config['PidDB.sol']['addr']
        contract_interface = smart_contract_config['PidDB.sol']['abi']
        pid_db = self.dark_gateway.w3.eth.contract(address=contract_addr, abi=ast.literal_eval(contract_interface))
        # invoke_contract(w3,account,chain_id, pid_db , 'set_uuid_provider' ,(uuid_provider_addr) )
        # logging.info("        - uuid provider configured")
        configured_contracts['PidDB'] = pid_db

        ##
        ## Search TermService
        ##
        logging.info("    Configuring dARK UrlService:")
        url_db_addr = smart_contract_config['UrlDB.sol']['addr']
        contract_addr = smart_contract_config['UrlService.sol']['addr']
        contract_interface = smart_contract_config['UrlService.sol']['abi']
        url_service = self.dark_gateway.w3.eth.contract(address=contract_addr, abi=ast.literal_eval(contract_interface))
        #send tx
        sign_tx = self.dark_gateway.signTransaction(url_service,'set_db' ,(url_db_addr))
        receipt, tx_hash = invoke_contract_sync(self.dark_gateway,sign_tx)
        #TODO CHECK receipt['status'] == 1

        logging.info("        - db configured")
        configured_contracts['UrlService'] = url_service

        ##
        ## ExternalPID Service
        ##
        logging.info("    Configuring ExternalPIDService:")
        epid_db_addr = smart_contract_config['ExternalPidDB.sol']['addr']
        contract_addr = smart_contract_config['ExternalPIDService.sol']['addr']
        contract_interface = smart_contract_config['ExternalPIDService.sol']['abi']
        epid_service = self.dark_gateway.w3.eth.contract(address=contract_addr, abi=ast.literal_eval(contract_interface))
        sign_tx = self.dark_gateway.signTransaction(epid_service,'set_db' ,(epid_db_addr))
        receipt, tx_hash = invoke_contract_sync(self.dark_gateway,sign_tx)
        #TODO CHECK receipt['status'] == 1
        logging.info("        - db configured")
        configured_contracts['ExternalPIDService'] = epid_service

        ##
        ## dARK PID Service
        ##
        logging.info("    Configuring dARK PIDService:")
        pid_db_addr = smart_contract_config['PidDB.sol']['addr']
        contract_addr = smart_contract_config['PIDService.sol']['addr']
        contract_interface = smart_contract_config['PIDService.sol']['abi']

        pid_service = self.dark_gateway.w3.eth.contract(address=contract_addr, abi=ast.literal_eval(contract_interface))
        sign_tx = self.dark_gateway.signTransaction(pid_service,'set_db' ,(pid_db_addr))
        receipt, tx_hash = invoke_contract_sync(self.dark_gateway,sign_tx)
        logging.info("        - db configured")
        sign_tx = self.dark_gateway.signTransaction(pid_service,'set_externalpid_service' ,(epid_service.address))
        receipt, tx_hash = invoke_contract_sync(self.dark_gateway,sign_tx)
        logging.info("        - ExternalPIDService configured")
        sign_tx = self.dark_gateway.signTransaction(pid_service,'set_url_service' ,(url_service.address))
        receipt, tx_hash = invoke_contract_sync(self.dark_gateway,sign_tx)
        logging.info("        - UrlService configured")
        sign_tx = self.dark_gateway.signTransaction(pid_service,'set_auth_service' ,(auth_service.address))
        receipt, tx_hash = invoke_contract_sync(self.dark_gateway,sign_tx)
        logging.info("        - authoritiesService configured")
        configured_contracts['PIDService'] = pid_service

        ### all set
        initial_acc_balance
        final_acc_balance = self.dark_gateway.get_account_balance()
        logging.info("    account final balance : {}".format(final_acc_balance))
        logging.info("    spent  {} ether during the deployment".format(initial_acc_balance-final_acc_balance))
        logging.info("All set... Services configured.")
        logging.info("")

    
    def configure_noid_provider(self,deployed_contracts_config_path,noid_config_path):
        logging.info("> Configure noid provider...")
        # read deployd contracts
        smart_contract_config = ConfigParser()
        smart_contract_config.read(deployed_contracts_config_path)

        # retriver noid parameters
        noid_config = ConfigParser()
        noid_config.read(noid_config_path)
        nam = str(noid_config['one-noid-to-rule-them-all']['nam'])
        ror_id = str(noid_config['one-noid-to-rule-them-all']['ror_id'])
        dshoulder_prefix = str(noid_config['one-noid-to-rule-them-all']['dshoulder_prefix'])
        noid_len = int(noid_config['one-noid-to-rule-them-all']['noid_len'])

        initial_acc_balance = self.dark_gateway.get_account_balance()
        logging.info("    account initial balance : " + str(initial_acc_balance) )
        logging.info("    Loading AuthoritiesService:")
        #loading autority contract
        contract_addr = smart_contract_config['AuthoritiesService.sol']['addr']
        contract_interface = smart_contract_config['AuthoritiesService.sol']['abi']
        auth_service = self.dark_gateway.w3.eth.contract(address=contract_addr, abi=ast.literal_eval(contract_interface))
        logging.info("    Creating a DNAM for {} (prefix={})".format(ror_id,dshoulder_prefix))
        sign_tx = self.dark_gateway.signTransaction(auth_service,'create_dnam' , ror_id , dshoulder_prefix, self.dark_gateway.authority_addr)
        recipt_tx, tx_hash = invoke_contract_sync(self.dark_gateway,sign_tx)
        auth_id = recipt_tx['logs'][0]['topics'][1]
        logging.info("    Configuring a DNAM noid provider at {}".format(auth_id))
        sign_tx = self.dark_gateway.signTransaction(auth_service,'configure_noid_provider_dnma' , nam, auth_id , noid_len , 1)
        recipt_tx, tx_hash = invoke_contract_sync(self.dark_gateway,sign_tx)
        logging.info("    Created noid provider for {} with {} digitis".format(nam,noid_len))
        noid_addr = recipt_tx['logs'][0]['topics'][1][12:]
        logging.info("    dARK is readty to be used!")
        # noid_addr # endereco do contrato



