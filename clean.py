import os

###
### VARIABLES
###

PROJECT_ROOT = os.path.dirname(os.path.realpath(__file__))

config_file_path = os.path.join(PROJECT_ROOT,'config.ini')
noid_provider_config_path = os.path.join(PROJECT_ROOT,'noid_provider_config.ini')
deployed_contracts_config_path = os.path.join(PROJECT_ROOT,'deployed_contracts.ini')


try:
    os.remove(deployed_contracts_config_path)
except FileNotFoundError:
    print("The system is alredy clean!")