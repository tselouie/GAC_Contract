//This file was used to test multi-sig wallet transaction with WITHDRAW. Currently is NOT being used.
const abi = require("../artifacts/contracts/Goodfellas.sol/GoodFellas.json");
const ethers = require("ethers");
const contractABI = abi.abi;
const contractAddress = 0xF5bC5b68ec5de41c7022b47A9a38ae269F929f2a;

const main = async () => {

    const provider = new ethers.providers.Web3Provider('0x3F99E37c9F6c3D0E81938B90a0adE08565E32178');
    const signer = provider.getSigner();
    const connectedContract = new ethers.Contract(
        contractAddress,
        contractABI,
        signer
    )

    overrides = {
        gasLimit: 500000,
        gasPrice: ethers.utils.parseUnits('150', 'gwei').toString(),
        type: 1,
        accessList: [
            {
                address: "0x2b5613cD3F60096F4e6658AdB7b8249BF464A85E", // admin gnosis safe proxy address
                storageKeys: [
                    "0x0000000000000000000000000000000000000000000000000000000000000000"
                ]
            },
            {
                address: '0xDaB5dc22350f9a6Aff03Cf3D9341aAD0ba42d2a6',  // gnosis safe master address? not sure if this is it
                storageKeys: []
            }
        ]
    }

    let withdrawTxn = await contract.withdraw(overrides)
    console.log({ withdrawTxn })
    resolved = await withdrawTxn.wait()
    console.log({ resolved })
  };
  
  const runMain = async () => {
    try {
        //deploy the contract
      await main();


      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();




