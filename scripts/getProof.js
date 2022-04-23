const keccak256 = require('keccak256');
const toHex = require('to-hex');
const { MerkleTree } = require('merkletreejs');
const {whitelist} = require("./data/whitelist.json");
const walletID = '0x3f99e37c9f6c3d0e81938b90a0ade08565e32178';
async function runProof(leafToVerify,whitelist) {
    let tree;
    let leaf;
    let leafIndex;
    let whitelistDataResponse = whitelist;
  
    const generateMerkleTree = async (whitelistDataResponse, leafToVerify) => {
      try {
        tree = new MerkleTree(whitelistDataResponse, keccak256, {
          sortPairs: true,
          sortLeaves: true,
          sort: true,
          hashLeaves: true
        });
        leaf = leafToVerify;
      } catch (e) {
        console.log(e);
      }
    }
  
    /**
     * Using the selected leaf value, lookup the corresponding hash
     * and index from the Merkle Tree Summary json file
    */
    const getLeafHashFromTreeSummary = (leafToVerify) => {
      try {
        const leafHash = `0x${keccak256(leafToVerify).toString('hex')}`;
        console.log(tree.getLeafIndex(leafHash), 'leafIndex');
        leafIndex = tree.getLeafIndex(leafHash);
      } catch (e) {
        console.log(e);
      }
    }
  
  
    const getProof = () => {
      try {
        if (leafIndex === -1) {
          console.log('Error: value does not exist within the list');
          return {
            leaf: leaf,
            errorMsg: 'Error: value does not exist within the list'
          }
        } 
        
        const leaves = tree.getHexLeaves();
        const proof = tree.getHexProof(leaves[leafIndex]);
        const leafValueHex = toHex(leaf);
    
        const proofObj = {
            leafValue: leaf,
            leafHex: leafValueHex,
            leafHash: leaves[leafIndex],
            proof: proof
        };
        let parsedProof = proof.reduce((prevValue,currValue) => prevValue.concat(currValue,','),'');
        parsedProof = parsedProof.slice(0, -1);
        console.log('proof obj before check', proofObj);
        console.log(`Proof generated for ${leaf}`);
        console.log(`Proof String is: \n${parsedProof}` );
    
        return proofObj;
      } catch (e) {
        console.log(e);
      }
    }
  
    if (whitelistDataResponse) {
      await generateMerkleTree(whitelistDataResponse, leafToVerify);
      // pass in a leaf value to generate a proof
      getLeafHashFromTreeSummary(leaf);
      return getProof(); 
    } else {
      console.log(`Error: IPFS URI Invalid`);
    }
    return { errorMsg: 'Error: IPFS whitelist link is invalid' }
  }




runProof(walletID,whitelist)
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
