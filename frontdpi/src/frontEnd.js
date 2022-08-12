import logo from './blocks.jpg';
import {useState, useEffect } from 'react';
import {ethers} from 'ethers';
import abiContract from './abiContract.json';
import ErrorMessage from "./ErrorMessage";


const FrontEnd = () => {

    const[message, setMessage] = useState('Status Connection: Waiting...');
    const[messageU, setMessageU] = useState('Wait UUID...');
    const [error, setError] = useState();
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
        const signerAddress = await signer.getAddress();
        const addU = '0x35edddC7dA46ffbFAE7a92e5C858C4152430EEa9';
        const constract = new ethers.Contract(addU, abiContract, signer);
        //atribuindo um uuid
        const uuidPi = await constract.assingUUID();
        const txReceipt = await provider.getTransactionReceipt(uuidPi.hash);
        console.log(txReceipt);
        const uuidFull = txReceipt.logs[0].topics[1];
        console.log(uuidFull);
        const uuid = uuidFull.substring(0,34);
        //este é o uuid e será usado nos outros metodos.
        console.log(uuid);
        //atribuindo um link externo
        const setExtLink = await constract.add_externalLinks( uuid , 'um_link_externo_qualquer');
        console.log(setExtLink);
        //atribuindo um payload
        const setPaylod = await constract.set_payload( uuid , 'payload_qualquer');
        console.log(setPaylod);
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
                <label htmlFor="name">Title (Payload)<span>*</span></label>
                <input id="name" type="text" name="name" placeholder="Ex: Blockchain applied in nanosatellites" required/>
            </div>
            <div className="item">
                <div className="name-item">
                    <div>
                        <label htmlFor="ext_pid">External PID<span>*</span></label>
                        <input id="ext_pid" type="text" name="ext_pid"/>
                    </div>
                    <div>
                        <label htmlFor="url">Url (External Link)</label>
                        <input id="url" type="text" name="url" />
                    </div>
                </div>
                <div className="item">
                    <label htmlFor="search_keys">Search keys<span>*</span></label>
                    <input id="search_keys" type="text" name="search_keys" placeholder="Ex: Blockchain; nanosatellites; communications"/>
                </div>
            </div>
            {/* <div className="row">
                <div className="btn-block">
                    <button> Submit</button>
                </div>
            </div> */}
            <input type="button" value="Get UUID" onClick={evt => handleUuid()} />
        </form>
        </div>
    </header>
  );
}

export default FrontEnd;