import sys
import os


from flask import Flask , jsonify , render_template
# from flask import render_template, request, Flask, g, send_from_directory, abort, jsonify

from web3 import Web3

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
template_dir = os.path.join(setup.PROJECT_ROOT,'templates')
app = Flask(__name__,template_folder=template_dir)

app.config['JSON_AS_ASCII'] = False #utf8
app.config['JSON_SORT_KEYS'] = False #prevent sorting json

@app.route('/')
def index():
    return render_template('home.html')

@app.get('/search/<term>')
def search(term):
    try:
        search_term = sete_db.caller.get(term) # o correto e mover isso para o servico
        print(search_term)
        search_term_id = Web3.toHex(search_term[0])
        print(search_term_id)
        raw_pids = sete_db.caller.get_pids(search_term_id)
        pids = []
        formated_pids = []
        for pid in raw_pids:
            pid = Web3.toHex(pid)
            pids.append(pid)
            fpid = str(pid[2:8])+'-'+str(pid[8:12])+'-'+str(pid[12:16])+'-'+str(pid[16:20])+'-'+str(pid[20:])
            formated_pids.append(fpid)

        resp = jsonify({'pids': pids, 'formated_pids': formated_pids})

    except ValueError as e:
        resp = jsonify({'status' : 'Unable to recovery (' + str(term) + ')', 'block_chain_error' : str(e)},)
    
    return resp, 200

@app.get('/get/dpi/<dpi_id>')
def get_pid(dpi_id):
    try:
        dpi_obect = dpid_db.caller.get(dpi_id)
        
        external_pids = []
        for ext_pid in dpi_obect[2]:
            # print(ext_pid)
            # print(type(ext_pid))
            # epid = epid_db.caller.get(ext_pid)
            ext_pid = Web3.toHex(ext_pid)
            # epid = epid_db.functions.get(ext_pid).call()
            get_func = epid_db.get_function_by_signature('get(bytes32)')
            epid = get_func(ext_pid).call()
            
            
            # print(ext_pid)

            pid_object = {'id': ext_pid, 
                            'schema:' : epid[3] , 'value' : epid[2], 
                            'owner:' : epid[-1]
                        }
            external_pids.append(pid_object)
        
        external_links = []
        for ext_link in dpi_obect[4]:
            external_links.append(ext_link)

        payload = dpi_obect[-2]
        owner = dpi_obect[-1]
        
        resp_dict = {
                        'external_pids' : external_pids,
                        'payload': payload,
                        'external_links' : external_links,
                        'owner' : owner,
                    }
        
        if len(external_links) == 0:
            del resp_dict['external_links']
        
        if len(external_pids) == 0:
            del resp_dict['external_pids']

        resp = jsonify(resp_dict)
    except ValueError as e:
        resp = jsonify({'status' : 'Unable to recovery (' + str(dpi_id) + ')', 'block_chain_error' : str(e)},)
    # web3.exceptions.ValidationError:
    
    return resp, 200    

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)