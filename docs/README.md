
# dARK Documentation


This folder contains the dARK Project Documents


**Documentarion Tools**

The documentation was build usin the visual studio code and and the [mermaid markup languege](https://mermaid.live). We also use the following extensions.


> [Visual Studio Draw.io Integration](https://marketplace.visualstudio.com/items?itemName=hediet.vscode-drawio)
> 
>[Markdown Preview Mermaid Support](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid)


# dARK Overview

The dARK has three majors components

```mermaid
flowchart LR
    %% {init: {'theme': 'neutral' } }%%

    %% linkStyle default stroke-width:3px
	
    classDef white fill:white,stroke:#000,stroke-width:2px,color:#000
    classDef allwhite fill:white,stroke:#fff,stroke-width:2px,color:#000
	%% classDef yellow fill:#fffd75,stroke:#000,stroke-width:2px,color:#000
	%% classDef green fill:#93ff75,stroke:#000,stroke-width:2px,color:#000

    %% API{fa:fa-server Local \n API}
    %% API2{fa:fa-globe Azure \n API}
    %%  fa-cubes
    %% subgraph a1 [fa:fa-infinity API]
    %%     a[RFC]
    %% end

    subgraph center[fa:fa-star Galaxy Center]
        direction LR
        besu[fa:fa-vector-square \n dARK]
        ipfs[fa:fa-upload \n IPFS]

        besu .-> ipfs
    end

    %% subgraph ships [fa:fa-toolbox Star Ships]
    %% subgraph ships [fa:fa-tachometer-alt Star Ships]
    subgraph ships [fa:fa-rocket Star Ships]
        direction LR
        hyperdrive[fa:fa-user-astronaut \n HyperDriver]
    end

    subgraph service[fa:fa-satelite Services]
        direction LR
        dp[fas:fa-th\n Data Parser]
        mdb[(fa:fa-scroll \n Meta Database)]
        dqs[fa:fa-satellite-dish Quality Service]
        hqs[fa:fa-search \n Hubble Query Service]

        dp .-> mdb
        mdb .-> dqs
        dqs --> mdb
        mdb .-> hqs
    end



    %% users[fa:fa-users User]:::allwhite
    %% user[fa:fa-user-circle \n Clients]:::allwhite
    
    ships ---> center
    center ---> ships

    center ---> service
    service ---> center

    %% B["fab:fa-twitter for peace"]
    
    
    
    
    %% vNetIcon["<br /><img class='Icon' src='https://cdn-icons-png.flaticon.com/512/2758/2758881.png' /> \n Galaxy"]
    %% click DOCS "https://redgregory.notion.site/c154907e263f48fe979a792588f3875a?v=2aabab98f87f479da4b9a66d86d61b50"
```


## Galaxy Center

Description here

### PID Desing


dARK is based on the ARK PID system. Due to the decentralized capalities of the dARK it has unique characteristic. This characteristic are detailed in the [PID Desing](./dARK_pid/) documents.

### Blockchain Desing
TODO


## Star Ships

Description here

## Galaxy Satellites (Services)

Description here

# dARK Universe

```mermaid
flowchart LR
	
    classDef white fill:white,stroke:#000,stroke-width:2px,color:#000
    classDef allwhite fill:white,stroke:#fff,stroke-width:2px,color:#000


    subgraph un[Universe \n ]
        subgraph br[fa:fa-star BR Galaxy]
            direction LR
            a[fa:fa-building-columns Org A]
            b[fa:fa-building-columns Org B]
            a .- b
        end

        subgraph latam[fa:fa-star Latam Galaxy]
            direction LR
            sa[fa:fa-building-columns Org A]
            sb[fa:fa-building-columns Org B]
            sa .- sb
        end

        subgraph ue[fa:fa-star UE Galaxy]
            direction LR
            ua[fa:fa-building-columns Org A]
            ub[fa:fa-building-columns Org B]
            ua .- ub
        end

        br --- ue
        br --- latam
        latam --- ue
    end


    subgraph service[fa:fa-satelite Services]
        direction LR
        dqs[fa:fa-satellite-dish Quality Service]
        hqs[fa:fa-search \n Hubble Query Service]
    end

    un ---> service
    service ---> un
```