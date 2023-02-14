import pytest

from web3 import Web3

import sys
# sys.path.append('../../')

from dARK.util import setup
# compile_all,get_contract,deploy_contract_besu,populate_file_list,get_tx_params,
from dARK.util.libs import invoke_contract

# @pytest.fixture
# def w3():
#     return setup.load_blockchain_driver()

# @pytest.fixture
# def compile_contracts(w3):
#     return setup.compile()

# @pytest.fixturels
# def deploy_contracts(w3,compile_contracts):
#     return setup.deploy_contracts(w3,compile_contracts)

# @pytest.fixture
# def configured_contracts(w3,deploy_contracts):
#     return setup.configure_env(w3,deploy_contracts)

def test_uuid_attribution():
    #setup
    w3 = setup.load_blockchain_driver()
    compiled_contracts = setup.compile()
    deployed_contracts = setup.deploy_contracts(w3,compiled_contracts)
    configured_contracts = setup.configure_env(w3,deployed_contracts)

    chain_id,min_gas_price,pk = setup.get_exec_parameters()
    
    account = w3.eth.account.privateKeyToAccount(pk)

    pidService = configured_contracts['PIDService']
    pidDB = configured_contracts['PidDB']

    assert pidDB.caller.count() == 0
    recipt_tx = invoke_contract(w3,account,chain_id, pidService , 'assingUUID' )
    assert pidDB.caller.count() == 1
    
    pid_id = recipt_tx['logs'][0]['topics'][1]

    assert Web3.toHex(pidDB.caller.get_by_index(0)) == Web3.toHex(pid_id)
    #olhar no Entities libs as posicoes 0 ~ 9
    pid_object = pidDB.caller.get(pid_id[:16]) #recupera do os 16bits
    assert account.address == pid_object[8]
    