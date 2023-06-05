
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
        -uuid: bytes16
        -owner: address
        
        List~bytes32~search_terms
        List~bytes32~external_pids
        List~bytes32~urls
    }

    class SearchTerm{
        -id : bytes32
        -value : string
    }

    class ExternalPID{
        -id : bytes32
        -value : string
    }

    class URL{
        -id : bytes32
        -value : string
    }

    class Payload{
        -id: address
        -payload: string
        -payload_type
        -List~Relation_Type~payload_relations
    }

    
    class Payload_Relation{
        -id: address
        -relation_type: address
        -related_to: address
    }

    class Relation_Type{
        -id : address
        -type_name: string
    }

    class Payload_Type{
        <<enumeration>>
        PERSON
        ARTICLE
    }

    dARK "1" --o "*" Payload : has
    Payload "1" --o "1" Payload_Type : has
    Payload "1" --o "1" Payload_Relation : has
    Payload_Relation "1" --o "1" Relation_Type : has

    dARK "1" *--  "*" SearchTerm
    dARK "1" *--  "*" ExternalPID
    dARK "1" *--  "*" URL
```
