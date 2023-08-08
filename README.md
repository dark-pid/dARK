# dARK

> Table of contents :
>  - [How to run](#how-to-run)
>  - [dARK Parameters](#dark-parameters)

dARK

## How to run

In this section we detail how to deploy the dARK.

> dARK deployment steps:
>  1. [Configuring dARK](#dark-configuration)
>  1. [Requirement install procedures](#requirements-install-procedure)
>  1. [dARK deployment](#how-to-deploy-dark-on-the-blockchain)


<details>
<summary>System Requirements</summary>
    <ul>
        <li> python 3.10 </li>
        <li> pip </li>
        <li> docker </li>
        <li> docker-compose </li>
    </ul>
</details>

### dARK configuration

Rename the the example_config.ini to config.ini in project root directory of the project.

```bash
cp example_config.ini config.ini
```

The default parameters in the  __config.ini__ file assumes tha the [dark env](https://github.com/dark-pid/) is runing on the local machine. Thus, if you are using a diferent setup update the __config.ini__ file.

We also prove a [noid provider config file](./example_noid_provider_config.ini). Rename the example_noid_provider_config.ini to noid_provider_config.ini.

```bash
cp example_noid_provider_config.ini noid_provider_config.ini
```

### Requirements Install Procedure

```sh
python3 -m venv web3
```
```sh
source web3/bin/activate
```

```bash
pip install -r requirements.txt 
```

### How to deploy dARK on the blockchain

To deploy the dARK first you have to compile and deploy and configure the dARK contracts.

**Deploy contracts on chain**
```bash
python.exe .\deploy.py
```

**Configure the dARK Services and DataBases on Chain**
```bash
python.exe .\configure.py
```

This scripts will employ the config parameters to configure and deploy the dARK.

## dARK Parameters

details of the dARK parameters
TODO
- config.ini
- example_noid_provider_config.ini

### Availabels Wallets
To import an account chose one of the accounts listed in the genesis.json and copy the private key. For instance;

```
"privateKey" : "8f2a55949038a9610f50fb23b5883af3b4ecb3c3bb792cbcefbd1542c692be63",
"privateKey" : "c87509a1c067bbde78beb793e6fa76530b6382a4c0241e5e4a9ec0a0f44dc0d3",
"privateKey" : "ae6ae8e5ccbfb04590405997ee2d52d2b330726137b875053c36d94e974d162f",
```
