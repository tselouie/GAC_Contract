const keccak256 = require('keccak256');
const { MerkleTree } = require('merkletreejs');
const {whitelist} = require("./data/whitelist.json");
async function main() {
  try{
    console.log(whitelist)
//create a  new merkle tree insance with given whitelist
//@param whitelist is the whitelist
//@param keccak256 is the type of encryption imported for the merkle tree standard in ethers
  let tree = new MerkleTree(whitelist,keccak256,{
    sortPairs: true,
    sortLeaves: true,
    sort: true,
    hashLeaves: true
  })
  const root = tree.getHexRoot();

  console.log('Your root is:' + root)

}catch(err){
  console.log(err)
}

}


main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
