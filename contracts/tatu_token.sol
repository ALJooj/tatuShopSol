// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "./ERC721.sol";

import "./ERC721URIStorage.sol";

contract MyToken is ERC721, ERC721URIStorage {
    address public owner;
    uint public currentTokenId;
    bool public isInCollection;

    constructor() ERC721("MyToken", "MTK") {
        owner = msg.sender;
    }

    function safeMint(address to, string calldata tokenId) public returns(uint){
        // require(msg.sender != 0x0165878A594ca255338adfa4d48449f69242Eb8F, 'found an issue!');
        require(owner == msg.sender, "not an owner!123");
        currentTokenId++;
        _safeMint(to, currentTokenId);
        _setTokenURI(currentTokenId, tokenId);

        
        return currentTokenId;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _baseURI() internal pure override returns(string memory) {
        return "ipfs://";
    }

    function _burn(uint tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(
        uint tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint tokenId) internal override(ERC721) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}