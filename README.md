# dARK
dARK App

## Install

### python 
Virtual Enviroment
```
conda create --name web3 python=3.8 --file requirements.txt
```
or
```sh
python3 -m venv web3
```
```sh
source venv/web3/bin/activate
```

```
pip install -r requirements.txt 
```

## configure .ini

Create new files and call them config.ini and deployed_contracts.ini.
Copy the information from the examples into it.

Attention: Make sure the path is correct.

### start dev env


### Configure the wallet (metamask)

 - **Network Name**: dARK-dev
 - **RPC URL** : http://127.0.0.1:8545
 - **CHAIN ID** : 1337
 - **Currency Symbol** : dARK 
 - **Block Explorer URL** : http://127.0.0.1:25000

#### Import an account (with credit)

To import an account chose one of the accounts listed in the genesis.json and copy the private key. For instance;

```
"privateKey" : "8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63",
"privateKey" : "c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3",
"privateKey" : "ae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f",
```
