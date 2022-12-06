// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./tatu_token.sol";

contract TatuShop{
    address public owner;

    uint public FEE = 10;
    uint constant FEE2 = 5;

    uint constant DISCOUNT = 15;

    MyToken public tokenController;
    // author addres => author name => y/n
    mapping(address => mapping(string => bool)) public approvalAuthor;
    // collections addres(author's or users) collections name => array of ids  
    // спросить пропадает ли коллекция после извлечения
    // одной шт или она является не полной
    mapping(address => mapping(string => uint[])) public collections;
    // id => authors address
    mapping(uint => address) public NFTtoAuthor;
    // authors NFT mapping (authors tokenId => name) 
    mapping(uint => string) public authorsNFT;
    // token id => price
    mapping(uint => uint) public tokenPrices;
    // collections name => season
    mapping(string => string) public collectionSeason;
    // collections name => length
    // mapping(string => uint) public nameToLengthCol;

    constructor(address _tokenController) {
        owner = msg.sender;
        approvalAuthor[owner]['owner'] = true;
        tokenController = MyToken(_tokenController);
    }


    event CreatedNFT(string tokenURI, string author, address authorsAddr);
    event CreateCollection(uint[] ids, string _author, string collectionName);


    modifier ownerOnly() {
        require(msg.sender == owner, 'you are not the owner');
        _;
    }

    modifier authorModifier(address adr, string memory authName) {
        require(approvalAuthor[adr][authName]);
        _;
    }

    function setAuthor(
        address adr, string memory _authorName, bool decision
        ) ownerOnly public {
        approvalAuthor[adr][_authorName] = decision;
    } 

    function mintNFT(
        string calldata tokenURI, 
        string calldata _author,
        address _authorsAddr,
        uint recommendedPrice
        ) public ownerOnly {
            require(approvalAuthor[_authorsAddr][_author], "cant mint NFT for non author");
            uint _tokenId = tokenController.safeMint(msg.sender, tokenURI);
            authorsNFT[_tokenId] = _author;
            tokenPrices[_tokenId] = recommendedPrice;
            NFTtoAuthor[_tokenId] = _authorsAddr;
            emit CreatedNFT(tokenURI, _author, _authorsAddr);
    }

    function createCollection(
        uint[] memory ids, 
        string memory _author, 
        string memory collectionName,
        string memory _collectionSeason
        ) authorModifier(msg.sender, _author) public {
        require(
            ids.length > 1 &&
            ids.length <= 10,
            "wrong collections length!"
        );
        for (uint i=0; i < ids.length; i++){
            // comparing given ids authors in authorsNFT to 
            // _author
            require(keccak256(abi.encodePacked(authorsNFT[ids[i]])) == keccak256(abi.encodePacked(_author)));
        } // можно поставить вместо ников адреса
        
        // nameToLengthCol[collectionName] = ids.length;
        collections[msg.sender][collectionName] = ids;
        collectionSeason[_collectionSeason] = collectionName;
        emit CreateCollection(ids, _author, collectionName);
    }
    
    function buy(uint id) public payable {
        require(msg.value < tokenPrices[id], "not enought funds!");
        if (msg.value > tokenPrices[id])
            _makeRefund(msg.sender, msg.value - tokenPrices[id]);
        
        address _author = NFTtoAuthor[id];
        payable(_author).transfer(
            tokenPrices[id] - ((tokenPrices[id] * FEE) / 100)
        );
        tokenController.safeTransferFrom(address(this), msg.sender, id, bytes("0"));
        
        delete NFTtoAuthor[id];
        delete authorsNFT[id];
        delete tokenPrices[id];
    }

    // buy collection 
    function buyCollection(address authorsAddr ,string memory collectionsName) public payable {
        // require(collections[authorsAddr][collectionsName].length == nameToLengthCol[collectionsName]);

        uint priceOfCollection;

        for (uint i=0; i< collections[authorsAddr][collectionsName].length; i++){
            priceOfCollection += tokenPrices[i];
            require(collections[authorsAddr][collectionsName][i] != 0, "collection is not full!");
        }
        uint prices = (priceOfCollection - ((priceOfCollection * DISCOUNT) / 100));
        require(msg.value < prices,
         "not enought funds!");
        
        if (msg.value > prices)
            _makeRefund(msg.sender, msg.value - prices);
        uint _fee = true ? FEE2  : FEE;
        payable(authorsAddr).transfer(
            prices - ((prices * _fee) / 100)
        );

        for (uint i=0; i< collections[authorsAddr][collectionsName].length; i++){
            uint id = collections[authorsAddr][collectionsName][i];
            tokenController.safeTransferFrom(address(this), msg.sender, id, bytes("0"));
            delete NFTtoAuthor[id];
            delete authorsNFT[id];
            delete tokenPrices[id];
        }   
        delete collectionSeason[collectionsName]; 
        delete collections[authorsAddr][collectionsName];
    }

    function changeFee(uint newFee) public ownerOnly {
        FEE = newFee;
    }

    function withdraw() external ownerOnly {
        payable(owner).transfer(address(this).balance);
    }

    function _makeRefund(address sendTo, uint difference) internal {
        payable(sendTo).transfer(difference);
    }
}