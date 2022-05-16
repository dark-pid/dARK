
# Dπ App documentation

drawio files

- Tool :: [Visual Studio Draw.io Integration](https://marketplace.visualstudio.com/items?itemName=hediet.vscode-drawio)

## basic model

![model](/Dapp/docs/model.png)

## Next Features

- publication url
- Authorization 


## ID generartion rule

ID generation rule for *Researcher* and *Publication* are detailed above:

### Researcher ID

The researcher id strategy is generate a keccak256 of the researcher name.

### Publication ID

_name,_year,_authors,_publication_type