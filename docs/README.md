
![dARK Logo](figures/dARK_logo.png)

# dARK Documentation

This directory contains comprehensive documentation for the dARK (Decentralized Archival Resource Key) project.  It provides information for users, developers, and administrators who want to understand, use, contribute to, or deploy the dARK system.

## Contents

The documentation is organized into the following files and directories:

*   **`configuration_files.md`:** This document provides a detailed explanation of the various configuration files used by the dARK system, primarily `config.ini`, `noid_provider_config.ini`, and `deployed_contracts.ini`. It describes each parameter within these files, their purpose, allowed values, and how they affect the system's behavior.  This is crucial for setting up and customizing a dARK instance.  It covers both general settings and blockchain-specific configurations.

*   **`contribution_guide.md`:**  This guide outlines the process for contributing to the dARK project. It covers topics such as reporting bugs, suggesting features, submitting code changes (pull requests), coding style guidelines, and the overall development workflow. This document is essential for anyone who wants to contribute to the project's development. It includes details on how to open and resolve project issues, adapting aspects of standard issue workflows to the specifics of dARK.

*   **`technical_overview.md`:**  This document provides a deep dive into the technical architecture of the dARK system.  It covers the core components, data models, smart contract details, and key processes (like PID creation and resolution).  It includes diagrams (class diagrams and sequence diagrams) to illustrate the relationships between different parts of the system. The document explains:
    * The **dARK Core Layer**: the heart of the system.
    * **Interacting with dARK**: how to use the system through libraries, resolvers, and APIs.
    * The **dARK implementation details**: on-chain components, including smart contracts.

*   **`dARK_pid/` (Directory):**  This directory likely contains additional, more specialized documentation related to specific aspects of the dARK PID implementation.  This could include details on the NOID generation algorithm, metadata schemas, or other implementation-specific details.

*   **`diagrams/` (Directory):** This directory contains diagrams (e.g., UML diagrams, flowcharts, architectural diagrams) that visually represent different aspects of the dARK system. These diagrams are referenced from other documentation files (like `technical_overview.md`) to aid in understanding.

*   **`figures/` (Directory):** This directory likely contains images used within the documentation files, such as screenshots or other illustrative figures.

*   **`notebooks/` (Directory):**  This directory might contain Jupyter notebooks or other interactive documents that provide tutorials, examples, or demonstrations of how to use the dARK system.  This is a good place for practical, hands-on guides.

## Navigating the Documentation

*   **Start with `technical_overview.md`:** For a comprehensive understanding of the dARK system's architecture and technical details, begin with this file.
*   **Refer to `configuration_files.md`:** When deploying or configuring a dARK instance, this is your essential guide.
*   **Consult `contribution_guide.md`:** If you plan to contribute to the dARK project, read this document first.
*  **Explore `dARK_pid/`, `diagrams/`, `figures/` and `notebooks`**: For a complete understanding.

This structure provides a well-organized and comprehensive documentation set for the dARK project, covering various aspects from configuration and technical details to contribution guidelines. The use of separate files for different topics and the inclusion of diagrams and figures make the documentation easy to navigate and understand.



