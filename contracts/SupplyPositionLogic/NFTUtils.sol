// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "../DataStructure/Global.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract NFTUtils is IERC721Events {
    using Address for address;

    error ERC721AddressZeroIsNotAValidOwner();
    error ERC721InvalidTokenId();
    error ERC721ApprovalToCurrentOwner();
    error ERC721CallerIsNotOwnerNorApprovedForAll();
    error ERC721CallerIsNotOwnerNorApproved();
    error ERC721TransferToNonERC721ReceiverImplementer();
    error ERC721MintToTheZeroAddress();
    error ERC721TokenAlreadyMinted();
    error ERC721TransferToIncorrectOwner();
    error ERC721TransferToTheZeroAddress();
    error ERC721ApproveToCaller();

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal {
        _transfer(from, to, tokenId);
        if (!_checkOnERC721Received(from, to, tokenId, data)) { 
            revert ERC721TransferToNonERC721ReceiverImplementer(); 
        }
    }

    function _exists(uint256 tokenId) internal view returns (bool) {
        SupplyPosition storage sp = supplyPositionStorage();

        return sp.owner[tokenId] != address(0);
    }

    function _ownerOf(uint256 tokenId) internal view returns (address) {
        SupplyPosition storage sp = supplyPositionStorage();

        address owner = sp.owner[tokenId];
        if (owner == address(0)) { revert ERC721InvalidTokenId(); }
        return owner;
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address owner = _ownerOf(tokenId);
        return (spender == owner || _isApprovedForAll(owner, spender) || _getApproved(tokenId) == spender);
    }


    function _getApproved(uint256 tokenId) internal view returns (address) {
        if (!_exists(tokenId)) { revert ERC721InvalidTokenId(); }

        return supplyPositionStorage().tokenApproval[tokenId];
    }

    function _safeMint(address to, uint256 tokenId) internal {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal {
        _mint(to, tokenId);
        if (!_checkOnERC721Received(address(0), to, tokenId, data)) { 
            revert ERC721TransferToNonERC721ReceiverImplementer(); 
        }
    }

    function _mint(address to, uint256 tokenId) internal {
        SupplyPosition storage sp = supplyPositionStorage();

        if (to == address(0)) { revert ERC721MintToTheZeroAddress(); }
        if (_exists(tokenId)) { revert ERC721TokenAlreadyMinted(); }

        sp.balance[to] += 1;
        sp.owner[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal {
        SupplyPosition storage sp = supplyPositionStorage();

        address owner = _ownerOf(tokenId);

        // Clear approvals
        _approve(address(0), tokenId);

        sp.balance[owner] -= 1;
        delete sp.owner[tokenId];

        emit Transfer(owner, address(0), tokenId);
    }

    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        SupplyPosition storage sp = supplyPositionStorage();

        if (_ownerOf(tokenId) != from) { revert ERC721TransferToIncorrectOwner(); }
        if (to == address(0)) { revert ERC721TransferToTheZeroAddress(); }

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        sp.balance[from] -= 1;
        sp.balance[to] += 1;
        sp.owner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal {
        SupplyPosition storage sp = supplyPositionStorage();

        sp.tokenApproval[tokenId] = to;
        emit Approval(_ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal {
        SupplyPosition storage sp = supplyPositionStorage();

        if (owner == operator) { revert ERC721ApproveToCaller(); }
        sp.operatorApproval[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    
    function _isApprovedForAll(address owner, address operator) internal view returns (bool) {
        return supplyPositionStorage().operatorApproval[owner][operator];
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal returns (bool) {
        if (to.isContract()) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert ERC721TransferToNonERC721ReceiverImplementer();
                } else {
                    /* solhint-disable-next-line no-inline-assembly */
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}