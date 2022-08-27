import logo from './blocks.jpg';
import {useState, useEffect } from 'react';
import {ethers} from 'ethers';
import abiContract from './abiContract.json';
import ErrorMessage from "./ErrorMessage";


const FrontEnd = () => {

    const[message, setMessage] = useState('Status Connection: Waiting...');
    const[messageU, setMessageU] = useState('Wait UUID...');
    const [error, setError] = useState();
    const [title, setTitle] = useState('');
    const [metaData, setMetadata] = useState('');
    const [urlExternal, setUrlExternal] = useState('');
    const [pidExternal, setPidExternal] = useState('');
    const [searchTerm, setSearchTerm] = useState('');
    const [contractInfo, setContractInfo] = useState({
        address: "-"
    });

    async function connect(){
        if(!window.ethereum)
        return setMessage('No Meta Mask installed!');

        setMessage('Trying to connect...');

        await window.ethereum.send('eth_requestAccounts');

        const provider = new ethers.providers.Web3Provider(window.ethereum);

        const balance = await provider.getBalance('0xFE3B557E8Fb62b89F4916B721be55cEb828dBd73');

        setMessage('O Saldo de sua carteira é: ' + ethers.utils.formatEther(balance.toString())+'  pi');

    }

    const handleUuid = async (e) => {
        

        //e.preventDefault();
        var myAddress = "0xfe3b557e8fb62b89f4916b721be55ceb828dbd73";
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        await provider.send("eth_requestAccounts", []);
        const signer = await provider.getSigner();
        //console.log(signer);
        const signerAddress = await signer.getAddress();
        const addU = '0x0e57a9Cd6f39Db35876a34C9C8Ec117eE4d51D60'; //pedando este addr do notebook
        console.log(`Você digitou o titulo: ${title}`);
        console.log(`Você digitou o pid externo: ${pidExternal}`);
        console.log(`Você digitou o link externo: ${urlExternal}`);
        console.log(`Você digitou os termos: ${searchTerm}`);
        console.log('Montando JSON para payload....');
        /*Setando dados no payload  */
        let payloadJson = 
            "{" +
                "title:" + `${title},` +
                "External PID: " + `${pidExternal},` +
                "Enternal Url: " +  `${urlExternal},` +
                "Search Terms:" +  `${searchTerm},` +
            "}"
        console.log(payloadJson);
        const constract = new ethers.Contract(addU, abiContract, signer);
        //atribuindo um uuid
        const darkId = await constract.assingID(signerAddress);
        console.log(darkId);
        const txReceipt = await provider.getTransactionReceipt(darkId.hash);
        const darkReceipt = txReceipt.logs[0].topics[1];
        console.log(`O recibo da transação da criacao de um dArk: ${darkReceipt}`);
        
        
        console.log("Adicionando payload....");
        const payload = await constract.set_payload(darkReceipt, payloadJson);
        console.log(payload);


        // const setExtLink = await constract.add_externalLinks( uuid , urlExternal);
        // console.log(setExtLink);
        // //atribuindo um payload
        // const setPaylod = await constract.set_payload( uuid , metaData);
        // console.log(setPaylod);
        //atribuindo um pid externo
        // const setSearcTerm = await constract.add_searchTerm( uuid , 'termo_de_busca');
        // console.log(setSearcTerm);
        //atribuindo um pid externo

        
        // setMessageU({
        //     UUID: uuid,
            
        // });
    }
  return ( 
    <header >
        <div className="App" >
        <img src={logo} className="App-logo" alt="logo" />
        <p></p>
        </div>
        <div className="testbox">
        <form method="get">
            <div className="banner">
                <h1>Create your Persistent Identifier</h1>
            </div>
            <p>
                <b>Welcome</b><code> To DPi!</code> <small><font color="red">Connect to your wallet to proceed!</font></small>
            </p>
            <input type="button" value="Connect" onClick={evt => connect()} />
            <p className="txt-center"><font color="red">{JSON.stringify(message)}</font></p>
            <p></p>
            {/* <input type="button" value="Get UUID" onClick={evt => handleUuid()} /> */}
            {/* <p className="txt-center"><font color="success">{JSON.stringify(messageU)}</font></p> */}
            <div className="item">
                <label htmlFor="title">Title<span>*</span></label>
                <input id="title" type="text" name="title" onChange={(e) => setTitle(e.target.value)} placeholder="Ex: Blockchain applied in nanosatellites" required/>
            </div>
            <div className="item">
                <div className="name-item">
                    <div>
                        <label htmlFor="ext_pid">External PID<span></span></label>
                        <input id="ext_pid" type="text" name="ext_pid"  onChange={(e) => setPidExternal(e.target.value)}/>
                    </div>
                    <div>
                        <label htmlFor="urlExternal">Url (External Link)<span>*</span></label>
                        <input id="urlExternal" type="text" name="urlExternal" onChange={(e) => setUrlExternal(e.target.value)} />
                    </div>
                </div>
                <div className="item">
                    <label htmlFor="search_keys">Search keys<span></span></label>
                    <input id="search_keys" type="text" name="search_keys" onChange={(e) => setSearchTerm(e.target.value)} placeholder="Ex: Blockchain; nanosatellites; communications"/>
                </div>
            </div>
            {/* <div className="row">
                <div className="btn-block">
                    <button> Submit</button>
                </div>
            </div> */}
            <input type="button" value="Submeter" onClick={evt => handleUuid()} />
        </form>
        </div>
    </header>
  );
}

export default FrontEnd;
