
const deployContract = async () => {
    const contractName = 'Goodfellas'
    const networkName = 'rinkeby';
    const payees = ['0x3F99E37c9F6c3D0E81938B90a0adE08565E32178','0x99B325e95b4060865208cC159cCB9DA51EbbF299']
    const shares = [93,7]
    const openseaProxyAddress = '0xa5409ec958c83c3f309868babaca7c86dcb077c1'
    const maxGAC = 5555;
    const maxCommunitySaleGAC = 1665;
    const maxGifted = 290;
    
    //argument order for smart contract constructor
    const args = [
      payees,
      shares,
      openseaProxyAddress,
      maxGAC,
      maxCommunitySaleGAC,
      maxGifted
    ] 
    //deploy contract using parameters
    const nftContractFactory = await hre.ethers.getContractFactory(contractName);   //Grab the contract from API
    const nftContract = await nftContractFactory.deploy(payees,shares,openseaProxyAddress,maxGAC,maxCommunitySaleGAC,maxGifted);
    await nftContract.deployed();
    console.log("Contract deployed to:", nftContract.address);
    console.log(`Verify with: \n npx hardhat verify --network ${networkName} ${nftContract.address} --constructor-args scripts/arguments.js`)
  };
  


  const runMain = async () => {
    try {
        //deploy the contract
      await deployContract();

      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();