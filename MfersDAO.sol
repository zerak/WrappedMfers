// SPDX-License-Identifier: MIT

/*
  __  __  __               ____    _    ___  
 |  \/  |/ _| ___ _ __ ___|  _ \  / \  / _ \ 
 | |\/| | |_ / _ \ '__/ __| | | |/ _ \| | | |
 | |  | |  _|  __/ |  \__ \ |_| / ___ \ |_| |
 |_|  |_|_|  \___|_|  |___/____/_/   \_\___/ 
                                             
*/

pragma solidity 0.8.15;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract MfersDAO is AccessControl, ERC721Enumerable, IERC721Receiver, ReentrancyGuard {
    string private _URI = "ipfs://QmWiQE65tmpYzcokCheQmng2DCM33DEhjXcPB6PanwpAZo/";
    IERC721 mToken = IERC721(0x79FCDEF22feeD20eDDacbB2587640e45491b757f); // mfer token

    constructor() ERC721("MfersDAO", "MfersDAO") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function wrap(uint256[] memory tokenIds) public nonReentrant {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            mToken.safeTransferFrom(msg.sender, address(this), tokenId);
            _safeMint(msg.sender, tokenId);
        }
    }

    function unwrap(uint256[] memory tokenIds) public nonReentrant {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            uint256 tokenId = tokenIds[i];
            require(ownerOf(tokenId) == msg.sender, "invalid ownership");
            mToken.safeTransferFrom(address(this), msg.sender, tokenId);
            _burn(tokenId);
        }
    }

    function _baseURI() internal view override returns (string memory) {
        return _URI;
    }
    
    function setBaseURI(string memory uri) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _URI = uri;
    }

    function onERC721Received(
        address /*operator*/,
        address /*from*/,
        uint256 /*tokenId*/,
        bytes calldata /*data*/
    ) public pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }

    // The following functions are overrides required by Solidity.
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
