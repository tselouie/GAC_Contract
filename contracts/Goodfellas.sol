//SPDX-License-Identifier: MIT
//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

contract Goodfellas is ERC721, Ownable, ReentrancyGuard, PaymentSplitter {
    using Counters for Counters.Counter;
    using Strings for uint256;
    enum Status { DISABLED, GIFT, PRIVATE, PUBLIC }
    Counters.Counter private tokenCounter;
    
    string private baseURI;
    address private openSeaProxyRegistryAddress;
    address[] public _team;
    bool private isOpenSeaProxyActive = true;

    uint256 public constant MAX_WL_GAC_PER_WALLET = 3;
    uint256 public maxApes;

    uint256 public PUBLIC_SALE_PRICE = 0.007 ether;
    
    Status public status = Status.DISABLED;

    uint256 public constant COMMUNITY_SALE_PRICE = 0.005 ether;
    uint256 public maxCommunitySaleGACs;
    bytes32 public communitySaleMerkleRoot;
    
    uint256 public maxGiftedGACs;
    uint256 public numGiftedGACs;

    mapping(address => uint256) public communityMintCounts;
    mapping(address => bool) public claimed;

    // ============ ACCESS CONTROL/SANITY MODIFIERS ============


    modifier canMintGACs(uint256 numberOfTokens) {

        require(
            tokenCounter.current() + numberOfTokens <=
                maxApes - maxGiftedGACs,
            "Not enough GACs remaining to mint"
        );
        _;
    }

    modifier canGiftGACs(uint256 num) {
        require(
            numGiftedGACs + num <= maxGiftedGACs,
            "Not enough GACs remaining to gift"
        );
        require(
            tokenCounter.current() + num <= maxApes,
            "Not enough GACs remaining to mint"
        );
        _;
    }

    modifier isCorrectPayment(uint256 price, uint256 numberOfTokens) {
        require(
            price * numberOfTokens == msg.value,
            "Incorrect ETH value sent value is "
        );
        _;
    }

    modifier isValidMerkleProof(bytes32[] calldata merkleProof, bytes32 root) {
        require(
            MerkleProof.verify(
                merkleProof,
                root,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "Address does not exist in list"
        );
        _;
    }

    constructor(
        address[] memory _payees,
        uint256[] memory _shares,
        address _openSeaProxyRegistryAddress,
        uint256 _maxApes,
        uint256 _maxCommunitySaleGACs,
        uint256 _maxGiftedGACs
    ) ERC721("GoodFellas Ape Club", "GAC") PaymentSplitter(_payees, _shares){
        _team = _payees;
        openSeaProxyRegistryAddress = _openSeaProxyRegistryAddress;
        maxApes = _maxApes;
        maxCommunitySaleGACs = _maxCommunitySaleGACs;
        maxGiftedGACs = _maxGiftedGACs;
    }

    // ============ PUBLIC FUNCTIONS FOR MINTING ============

    function mint(uint256 numberOfTokens)
        external
        payable
        nonReentrant
        isCorrectPayment(PUBLIC_SALE_PRICE, numberOfTokens)
        canMintGACs(numberOfTokens)
    {  
         require(
            status == Status.PUBLIC,
            "Public Sale Inactive"
        );
        require(
            numberOfTokens <= 5,
            "Max GACs you can mint at one time is five"
        );
        for (uint256 i = 0; i < numberOfTokens; i++) {
            _safeMint(msg.sender, nextTokenId());
        }
    }

    function mintCommunitySale(
        uint8 numberOfTokens,
        bytes32[] calldata merkleProof
    )
        external
        payable
        nonReentrant
        canMintGACs(numberOfTokens)
        isCorrectPayment(COMMUNITY_SALE_PRICE, numberOfTokens)
        isValidMerkleProof(merkleProof, communitySaleMerkleRoot)
    {
        uint256 numAlreadyMinted = communityMintCounts[msg.sender];

        require(
            status == Status.PRIVATE,
            "Private Sale Inactive"
        );

        require(
            numAlreadyMinted + numberOfTokens <= MAX_WL_GAC_PER_WALLET,
            "Max GACs to mint in community sale is three"
        );

        require(
            tokenCounter.current() + numberOfTokens <= maxCommunitySaleGACs,
            "Not enough GACs remaining to mint"
        );

        communityMintCounts[msg.sender] = numAlreadyMinted + numberOfTokens;

        for (uint256 i = 0; i < numberOfTokens; i++) {
            _safeMint(msg.sender, nextTokenId());
        }
    }

    function claim()
        external
        canGiftGACs(1)
    {
        require(
            status == Status.GIFT,
            "Gift Claim Inactive"
        );
        claimed[msg.sender] = true;
        numGiftedGACs += 1;

        _safeMint(msg.sender, nextTokenId());
    }
    // ============ PUBLIC READ-ONLY FUNCTIONS ============

    function getBaseURI() external view returns (string memory) {
        return baseURI;
    }

    function getLastTokenId() external view returns (uint256) {
        return tokenCounter.current();
    }
    function getStatusString() public view returns (string memory) {
        Status temp = status;
        if (temp == Status.DISABLED) return "DISABLED";
        if (temp == Status.GIFT) return "GIFT";
        if (temp == Status.PRIVATE) return "PRIVATE";
        if (temp == Status.PUBLIC) return "PUBLIC";
        return "";
        }

    // ============ OWNER-ONLY ADMIN FUNCTIONS ============

    function setBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    // function to disable gasless listings for security in case
    // opensea ever shuts down or is compromised
    function setIsOpenSeaProxyActive(bool _isOpenSeaProxyActive)
        external
        onlyOwner
    {
        isOpenSeaProxyActive = _isOpenSeaProxyActive;
    }



   function setStatus(uint _status) external onlyOwner {
       status = Status(_status);
   }

    function setPublicMintPrice(uint256 newMintPrice) external onlyOwner {
        PUBLIC_SALE_PRICE = newMintPrice;
    }
    
      function setCommunityListMerkleRoot(bytes32 merkleRoot) external onlyOwner {
        communitySaleMerkleRoot = merkleRoot;
    }

      // RELEASE FUNDS VIA PAYMENTSPLITTER
    function releaseFunds() external onlyOwner {
        for (uint256 i = 0; i < _team.length; i++) {
            release(payable(_team[i]));
        }
    }

    function withdrawTokens(IERC20 token) public onlyOwner {
        uint256 balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);
    }

    // ============ SUPPORTING FUNCTIONS ============

    function nextTokenId() private returns (uint256) {
        tokenCounter.increment();
        return tokenCounter.current();
    }

    /**
     * @dev Override isApprovedForAll to allowlist user's OpenSea proxy accounts to enable gas-less listings.
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        override
        returns (bool)
    {
        // Get a reference to OpenSea's proxy registry contract by instantiating
        // the contract using the already existing address.
        ProxyRegistry proxyRegistry = ProxyRegistry(
            openSeaProxyRegistryAddress
        );
        if (
            isOpenSeaProxyActive &&
            address(proxyRegistry.proxies(owner)) == operator
        ) {
            return true;
        }

        return super.isApprovedForAll(owner, operator);
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "Nonexistent token");

        return
            string(abi.encodePacked(baseURI, "/", tokenId.toString(), ".json"));
    }

}

// These contract definitions are used to create a reference to the OpenSea
// ProxyRegistry contract by using the registry's address (see isApprovedForAll).
contract OwnableDelegateProxy {

}

contract ProxyRegistry {
    mapping(address => OwnableDelegateProxy) public proxies;
}