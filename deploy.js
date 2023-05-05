const Web3 = require('web3');
const fs = require('fs');

const web3 = new Web3('https://data-seed-prebsc-1-s1.binance.org:8545/');

const account = web3.eth.accounts.privateKeyToAccount('YOUR_PRIVATE_KEY');
web3.eth.accounts.wallet.add(account);

const bytecode = fs.readFileSync('./bin/CollectFirstNMw.bin', 'utf8');
const abi = fs.readFileSync('./abi/CollectFirstNMw.abi', 'utf8');

const contract = new web3.eth.Contract(JSON.parse(abi));

contract.deploy({
    data: bytecode,
    arguments: ['0x3963744012dadf90a9034ea1068f53108b1a3834', // treasury
                'YOUR_PUBLIC_KEY']
}).send({
    from: account.address,
    gas: 3000000,
    gasPrice: '30000000000'
}).then((newContractInstance) => {
    console.log('Contract deployed at address: ' + newContractInstance.options.address);
});
