# Basic Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, a sample script that deploys that contract, and an example of a task implementation, which simply lists the available accounts.

Try running some of the following tasks:

```shell
npx hardhat accounts
npx hardhat compile
npx hardhat clean
npx hardhat test
npx hardhat node
node scripts/sample-script.js
npx hardhat help
```

 HOW TO DEPLOY AND SETUP GOODFELLAS CONTRACT
 ```
 npx hardhat run scripts/deploy.js --network {networkName}
```
    -once deployed use the new contract address in verify script
 //arguments are put into arguments.js because i could not put arrays into cmd line
```
 npx hardhat verify --network {networkName} {contractAddress} --constructor-args scripts/arguments.js
```
 Whitelist
 ---------
 1. Paste your white list in scripts/data/whitelist.json
 2. Assuming your in the root folder run ./scripts/getRoot.js (this will return your root address in console)
 3. set the whitelist address on the contract at etherscan.io