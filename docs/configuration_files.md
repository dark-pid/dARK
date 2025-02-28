# dARK Configuration 


The dARK system utilizes three primary configuration files, all located in the project's root directory. These files control various aspects of the dARK system, from blockchain network connection details to smart contract settings and NOID (identifier generation) parameters.

#### Table of Contents
  - [dARK Genreal Config (`config.ini`)](#dark-genreal-config-configini)
  - [dARK NOID Configuration (`noid_provider_config.ini`)](#dark-noid-configuration-noid_provider_configini)
  - [Deployed Contracts (`deployed_contracts.ini`)](#deployed-contracts-deployed_contractsini)



## dARK Genreal Config (`config.ini`)

The file (`config.ini`) provides configuration settings for interacting with a dARK blockchain network and deploying/interacting with the dARK smart contracts. It's structured using the INI file format.
The configuration file is divided into several sections:

#### `[base]`

This section contains general configuration parameters:

*   `blockchain_net`: Specifies the target blockchain network.  The value here (e.g., `dark-virtualenv`) should correspond to a section defining the network's specific parameters (see below). This setting determines which network configuration in the file will be used.
*   `dapp_dir`:  Specifies the directory where the dARK decentralized application (DApp) files are located.  This is likely where the HTML/JavaScript frontend resides.

#### `[dark-local]` and `[dark-virtualenv]` (Network Configurations)

These sections define the connection parameters for specific blockchain networks.  You can have multiple network configurations, and the `blockchain_net` setting in the `[base]` section selects which one is active. Each network configuration section contains:

*   `url`: The URL of the JSON-RPC endpoint for the blockchain node. This is how your application communicates with the blockchain.
    *   `dark-local`:  `http://127.0.0.1:8545` (typically used for a local development node).
    *   `dark-virtualenv`: `http://rpcnode:8545` (likely used for a virtual environment or Docker setup, where `rpcnode` is a hostname or service name).
*   `chain_id`: The Chain ID of the network. This is a unique identifier for the specific blockchain.  `1337` is a common Chain ID for local development networks (like Ganache or Hardhat).
*   `min_gas_price`: The minimum gas price (in Wei) that transactions should use.  This helps ensure transactions are processed in a timely manner.
*   `account_priv_key`: The *private key* of the Ethereum account that will be used to sign transactions.  

**IMPORTANT:** You can create your own network configuration for example `[my-dark-net]` and configure your own network.

#### `[smartcontracts]`

This section defines settings related to the Solidity smart contracts:

*   `solc_version`: The version of the Solidity compiler (`solc`) to use.  Ensure this matches the version supported by your development environment and the `pragma solidity` directive in your contracts.
*   `lib_dir`, `util_dir`, `db_dir`, `service_dir`: These specify the directories where different types of Solidity files are located. This helps organize your project.
    *    `lib_dir`: Contains reusable library contracts.
    *    `util_dir`: Contains utility contracts.
    *   `db_dir`: Contains contracts that manage data storage (database-like functionality).
    * `service_dir`: Contains contracts that provide core dARK services.
*   `lib_files`, `utils_files`, `dbs_files`, `service_files`:  These list the specific Solidity files within each directory.  The order might matter for compilation dependencies.

#### `[payload]`

This section defines the structure and attributes for a specific payload configuration:

*    `name`: A name to identify this payload definition (e.g., `basic2024a`).  This could be used to select different metadata schemas.
*  `attributes`: A space-separated list of attribute names that are expected to be present in the payload. This defines the schema for the metadata associated with dARK identifiers when using this payload configuration.  For example, a payload conforming to this definition might look like:
    ```json
        {
          "title": "My Research Paper",
          "author": "Dr. Jane Doe",
          "format": "thesis",
          "publishDate": "2024-10-27",
          "oai_identifier_str": "oai:example.org:12345"
        }
    ```
    This specifies which fields should be treated as searchable `search_terms`.


### Configuration Usage

This configuration file is likely used by a script or application (written in Python or another language) that interacts with the dARK blockchain. The script would:

1.  Read the `example_config.ini` file.
2.  Use the `[base]` section to determine the active network (`blockchain_net`).
3.  Load the network configuration from the corresponding section (e.g., `[dark-virtualenv]`).
4.  Use the network parameters (`url`, `chain_id`, `account_priv_key`) to connect to the blockchain and sign transactions.
5.  Use the `[smartcontracts]` section to locate and compile the Solidity contracts.
6.  Use the `[payload]` to create a new payload.
7.  Deploy the compiled contracts to the network (if necessary).
8.  Interact with the deployed contracts (e.g., register new dARK IDs, query for existing IDs).


## dARK NOID Configuration (`noid_provider_config.ini`)

This file (`example_noid_provider_config.ini`) provides configuration settings related to the NOID (Nice Opaque Identifier) service within the dARK (Decentralized Archival Resource Key) system.  This NOID service is responsible for generating unique and persistent identifiers. The file uses the INI format. This example uses the section name `[noid-configuration-name]`, indicating it configures a primary or central NOID service. It is important to metion that you can use any name in our example file we use `[one-noid-to-rule-them-all]`.

### Noid Config Name: `[noid-configuration-name]`

This section contains the parameters for configuring a specific NOID instance. The section name itself might be descriptive of its role (e.g., a central NOID service).

*   **`dnma_name`**:  The name of the Decentralized Name Mapping Authority (DNMA).  This represents the institution or organization responsible for managing a set of identifiers within the dARK network. Example: `IBICT`. This is the human-readable name.
*   **`dnma_contact_email`**: The contact email address for the DNMA.  This is used for communication related to the NOID service and identifier management. Example: `thiagonobrega@ibict.br`.
*   **`naan`**: The Name Assigning Authority Number (NAAN).  This is a globally unique identifier assigned to an organization by the ARK Alliance (or another authority) that allows it to mint ARK identifiers.  The NAAN forms the prefix of all ARK identifiers generated by this organization. Example: `8033`. This is a *crucial* identifier, linking the dARK instance to the global ARK infrastructure.
*   **`dshoulder_prefix`**: The default shoulder prefix. The "shoulder" is a part of the ARK identifier that comes after the NAAN and typically represents a sub-organization or collection within the DNMA. The 'd' indicates that this is a default shoulder. Example: `fkwf`. This value provides a default section within the institution for generated identifiers.
*   **`noid_len`**: The length (in characters) of the generated NOID part of the ARK identifier (the "blade").  This determines the maximum number of unique identifiers that can be generated under this shoulder. A longer `noid_len` allows for more identifiers. Example: `8`.  This directly impacts the capacity of the system.
*   **`payload_schema_name`**:  The name of the default payload schema to use when creating new dARK identifiers.  This refers to a predefined structure for the metadata associated with the identifier (likely defined elsewhere, such as in an `example_config.ini` file's `[payload]` section, as seen in previous examples). Example: `basic2024a`.  This connects the identifier generation to a specific metadata format.


## Deployed Contracts (`deployed_contracts.ini`)

This file is generated automatically when the contracts are deployed within the blockchain.
