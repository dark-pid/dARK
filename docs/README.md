
![dARK Logo](figures/dARK_logo.png)


# dARK Project Documents


![dark Overview](figures/macro_vision.svg)

<details>
<summary>dARK Governance Layer</summary>
Description here
</details>

<details>
<summary>dARK Core Layer</summary>
Description here
</details>

<details>
<summary>dARK Service Layer</summary>
Description here
</details>

<details>
<summary>dARK Users</summary>
Description here
</details>


# dARK Layers

## dARK Governance Layer

## dARK Core Layer

Description here

### dARK PID System

For further detail see [PID Desing](./dARK_pid/) section.

### dARK Core

BC Code

### dARK Metadata Storage

IPFS Code

## dARK Service Layer

## dARK Users

#  Project Status

| module | submodule | status | PoC   | release |
| ---    | ---       | ---  | :---: | :---: |
| dARK Governance Layer | - | - | - | - |
| dARK Core Layer | dARK | updating | [v1](https://doi.org/10.5281/zenodo.7442743) | - |
| dARK Core Layer | PiD Metadata | working | [v1](https://doi.org/10.5281/zenodo.7442743)  | - |
| dARK Core Layer | dARK Metadata Storage | on hold | - | - |
| dARK Service Layer | Data Extractor* | working | - | - |
| dARK Service Layer | Search Service | - | - | - |
| dARK Service Layer | Quality Service | - | - | - |
| dARK Users | HyperDrive | working | - | - |

HyperDrive : Founded by RNP

## Project Proof Of Concept (PoC)



<details>
<summary>PoC v1 </summary>
Washington Segundo, Lautaro Matas, Thiago Nóbrega, J. Edilson S. Filho, & Jesús Mena-Chalco. (2022). dARK: A decentralized blockchain implementation of ARK Persistent Identifiers (1.0). Zenodo. 
</details>

[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7442743.svg)](https://doi.org/10.5281/zenodo.7442743)


# Misc

<details>
 <summary>Documentarion Tools</summary>

The documentation was build usin the visual studio code and and the [mermaid markup languege](https://mermaid.live). We also use the following extensions.


> [Visual Studio Draw.io Integration](https://marketplace.visualstudio.com/items?itemName=hediet.vscode-drawio)
> 
> [Markdown Preview Mermaid Support](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid)

### Windows

1. Install scoop https://scoop.sh/

```
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser # Optional: Needed to run a remote script the first time
> irm get.scoop.sh | iex
```

2. Install MARP
```
scoop install marp
```

3. Export Files


```
marp .\presentation.md --pdf
marp .\presentation.md --html
```

If inside visual studio code use the full path of marp comand

```
C:\Users\thiag\scoop\shims\marp.exe .\presentation.md --pdf
```

TODO: add system marp to code ps path
</details>
