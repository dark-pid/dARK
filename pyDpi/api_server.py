import sys
import os


from flask import Flask , jsonify
# from flask import render_template, request, Flask, g, send_from_directory, abort, jsonify

import json
# import json
# import pandas as pd
# from web3 import Web3

from util import setup
from util.libs import invoke_contract

#
w3 = setup.load_blockchain_driver()
deployed_contracts = setup.load_deployed_smart_contracts(w3)
dpid_db = deployed_contracts['PidDB.sol']
epid_db = deployed_contracts['ExternalPidDB.sol']
sete_db = deployed_contracts['SearchTermDB.sol']

dpid_service = deployed_contracts['PIDService.sol']
epid_service = deployed_contracts['ExternalPIDService.sol']
sets_service = deployed_contracts['SearchTermService.sol']

chain_id,min_gas_price,pk = setup.get_exec_parameters()
account = w3.eth.account.privateKeyToAccount(pk)

# novo
app = Flask(__name__)
app.config['JSON_AS_ASCII'] = False #utf8

@app.route("/")
def helloworld():
    return "Hello World!"

@app.route("/get_data")
def getdata():
    data = {
        'name' : 'My Name',
        'url' : 'My URL'
    }
    return json.dumps(data)

@app.get('/get/<dpi_id>')
def get_pid(dpi_id):
    # dpid_db.caller.
    # print(dpi_id)
    dpi_obect = dpid_db.caller.get(dpi_id)
    print(dpi_id)
    print('---------')
    # print(len(dpi_obect[4]))
    # print(dpi_obect[4])

    external_links = []
    for ext_link in dpi_obect[4]:
        external_links.append(ext_link)
    
    payload = dpi_obect[-2]
    owner = dpi_obect[-1]
    
    resp_dict = {
                    'external_links' : external_links,
                    'payload': payload,
                    'owner' : owner,
                }
    
    if len(external_links) == 0:
        del resp_dict['external_links']
    
    resp = jsonify(resp_dict)
    
    
    
    
    return resp, 200

    # return str()
    

if __name__ == "__main__":
    app.run()