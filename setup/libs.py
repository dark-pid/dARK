#!/usr/bin/env python
# -*-coding:utf-8 -*-
'''
@File    :   libs.py
@Time    :   2022/04/21 11:03:55
@Author  :   Thiago Nóbrega 
@Contact :   thiagonobrega@gmail.com
'''

import time
import logging

from eth_tester.exceptions import TransactionFailed
from web3.exceptions import TransactionNotFound

import solcx

def compile_contract(contract_file,dapp_dir,dapp_libs,output_values=["abi",'bin',"bin-runtime"],solc_version="0.8.13"):
    contract_path = dapp_dir + contract_file
    l = dapp_libs.copy()
    l.insert(0,contract_path)

    
    comp = solcx.compile_files(l,output_values=output_values,solc_version=solc_version)
   #  import_remappings {"prefix": "path"}

    for k in comp.keys():
        if contract_file in k:
            return comp[k]
    # solcx.link_code
    raise Exception('This shouldnt happend')

def deploy_contract_dev(w3, contract_interface):
   tx_hash = w3.eth.contract(
      abi=contract_interface['abi'],
      bytecode=contract_interface['bin']).constructor().transact()

   address = w3.eth.get_transaction_receipt(tx_hash)['contractAddress']
   return address

def deploy_contract_besu(account,w3, contract_interface,gas=500000):
   # 1000000
   
   sc = w3.eth.contract( abi=contract_interface['abi'],
                           bytecode=contract_interface['bin']
                        )

   #   'gas': 6612388,   
   # 'gasPrice': w3.eth.gasPrice
   tx_params = {'from': account.address,
               'nonce': w3.eth.getTransactionCount(account.address),
               'gas': gas,
               # 'gasPrice': 1100, #//ETH per unit of gas
               # BESU_MIN_GAS_PRICE=1337
               # 'gasLimit': '0x24A22' #//max number of gas units the tx is allowed to use
               }

   tx_const = sc.constructor().buildTransaction(tx_params)
   signed_tx = account.signTransaction(tx_const)
   tx_hash = w3.eth.sendRawTransaction(signed_tx.rawTransaction)

   tx_receipt = None
   iter_count = 1

   # tx_receipt = w3.eth.waitForTransactionReceipt(tx_hash)

   while tx_receipt == None or iter_count < 30:
      logging.debug("Trying.. " + str(iter_count) + "/30 ...")
      time.sleep(2)
      try:
         tx_receipt = w3.eth.getTransactionReceipt(tx_hash)
         iter_count += 1
         return tx_receipt['contractAddress']
      except TransactionNotFound:
         iter_count += 1

   # tx_receipt['status'] 0x1 funcionou 0x0 nao foi feito o deploy
   if iter_count >= 29:
      logging.debug('Transacao lascou')
      
   return tx_receipt['contractAddress']