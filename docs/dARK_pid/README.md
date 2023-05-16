
# dARK PID Desing Documentation

dARK is based on ARK... 

TODO: improve description

# Important Points

Need to be detailed : 

- Specify dARK Objects (e.g., authors/publication)
- metadata structure
- metadata data storage (ipfs?)

# dARK Diagrams

## Class Diagram

```mermaid
classDiagram

    class dARK{
        +bytes16 uuid
        +String payload
        +address owner
    }

    class SearchTerm{
        +bytes32 id
        +String value
    }

    class ExternalPID{
        +bytes32 id
        +String value
    }

    class URL{
        +bytes32 id
        +String value
    }

    dARK "1" *--  "*" SearchTerm
    dARK "1" *--  "*" ExternalPID
    dARK "1" *--  "*" URL
```