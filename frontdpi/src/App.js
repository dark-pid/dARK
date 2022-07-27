import logo from './blocks.jpg';
import {useState, useEffect } from 'react';
import './App.css';
import {ethers} from 'ethers';
import abiContract from './abiContract.json';
import ErrorMessage from "./ErrorMessage";


function App() {

  const[message, setMessage] = useState('Status Connection: Waiting...');
  const[messageU, setMessageU] = useState('Wait UUID...');
  const [error, setError] = useState();
  

  async function connect(){
    if(!window.ethereum)
      return setMessage('No Meta Mask installed!');

    setMessage('Trying to connect...');

    await window.ethereum.send('eth_requestAccounts');

    const provider = new ethers.providers.Web3Provider(window.ethereum);

    const balance = await provider.getBalance('0xFE3B557E8Fb62b89F4916B721be55cEb828dBd73');

    setMessage('O Saldo de sua carteira é: ' + ethers.utils.formatEther(balance.toString())+'  pi');

  }

  async function getUuid(){

    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer =  provider.getSigner();
    const signerAddress = await signer.getAddress();
    const addU = '0xE6a114ba4eC2397b0960De6bE270178F3D5c9892';
    const abiU = abiContract; 
    // let contractInstance = new ethers.Contract(abiU,addU);
    // let encoded = contractInstance.method.UUIDProvider(signerAddress)
    
    //const getU = new ethers.Contract(addU, abiU ,provider);
    setMessageU({
      address: signerAddress,

    });

  }
  
  return (
    
    
  <header >
    <div className="App" >
      <img src={logo} className="App-logo" alt="logo" />
      <p></p>
    </div>
    <div class="testbox">
      <form method="get">
          <div class="banner">
              <h1>Create your Persistent Identifier</h1>
          </div>
          <p>
            <b>Welcome</b><code> To DPi!</code> <small><font color="red">Connect to your wallet to proceed!</font></small>
          </p>
          <input type="button" value="Connect" onClick={evt => connect()} />
          <p class="txt-center"><font color="red">{JSON.stringify(message)}</font></p>
          <p></p>
          <input type="button" value="Get UUID" onClick={evt => getUuid()} />
          <p class="txt-center"><font color="success">{JSON.stringify(messageU)}</font></p>
          <div class="item">
              <label for="name">Title<span>*</span></label>
              <input id="name" type="text" name="name" placeholder="Ex: Blockchain applied in nanosatellites" required/>
          </div>
          <div class="item">
              <div class="name-item">
              <div>
                  <label for="year">Year</label>
                  <input id="year" type="text" name="year"/>
              </div>
              <div>
                  <label for="publication_type">Publication Type</label>
                  <input id="publication_type" type="tel" name="publication_type" />
              </div>
              </div>
          </div>
          <div class="item">
              <div class="name-item">
                  <div>
                      <label for="authors">Authors<span>*</span></label>
                      <input id="authors" type="text" name="authors" required/>
                  </div>
                  <div>
                      <label for="advisor">Advisor</label>
                      <input id="advisor" type="text" name="advisor" />
                  </div>
              </div>
          </div>
          <div class="item">
              <div class="name-item">
                  <div>
                      <label for="ext_pid">External PID<span>*</span></label>
                      <input id="ext_pid" type="text" name="ext_pid" required/>
                  </div>
                  <div>
                    <label for="url">Url</label>
                    <input id="url" type="text" name="url" />
                  </div>
              </div>
              <div class="item">
                  <label for="search_keys">Search keys<span>*</span></label>
                  <input id="search_keys" type="text" name="search_keys" placeholder="Ex: Blockchain; nanosatellites; communications" required/>
              </div>
          </div>
          <div class="row">
            <div class="btn-block">
                <button> Submit</button>
            </div>
          </div>
      </form>
    </div>
  </header>

  );
}

export default App;
