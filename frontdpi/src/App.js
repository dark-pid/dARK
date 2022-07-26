import {useState} from 'react';
import './App.css';
import {ethers} from 'ethers';

function App() {

  const[message, setMessage] = useState('');

  async function connect(){
    if(!window.ethereum)
      return setMessage('No Meta Mask installed!');

    setMessage('Trying to connect...');

    await window.ethereum.send('eth_requestAccounts');

    const provider = new ethers.providers.Web3Provider(window.ethereum);

    const balance = await provider.getBalance('0xFE3B557E8Fb62b89F4916B721be55cEb828dBd73');

    setMessage('O Saldo de sua carteira é: ' + ethers.utils.formatEther(balance.toString()) +'  pi');

  }

  return (
    <div className="App">
      <input type="button" value="Connect" onClick={evt => connect()} />
      <p>{JSON.stringify(message)}</p>
      
    </div>
  );
}

export default App;
