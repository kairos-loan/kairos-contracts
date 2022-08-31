// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

import "../interface/IERC721.sol";
import "../DataStructure/Global.sol";

/// @title ERC721 Diamond Facet
/// @notice implements basic ERC721 for usage as a diamond facet
/// @dev based on OpenZeppelin's implementation
///     this is a minimalist implementation, notably missing are the
///     tokenURI, _baseURI, _beforeTokenTransfer and _afterTokenTransfer methods
/// @author Kairos protocol
abstract contract DiamondERC721 is IERC721 {
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

    error Unauthorized();

    // constructor equivalent is in the Initializer contract

    /// @dev don't use this method for inclusion in the facet function selectors
    ///     prefer the LibDiamond implementation for this method
    ///     it is included here for IERC721-compliance
    function supportsInterface(bytes4 interfaceId) public view returns (bool) {}

    function balanceOf(address owner) public view virtual returns (uint256) {
        SupplyPosition storage sp = supplyPositionStorage();

        if (owner == address(0)) { revert ERC721AddressZeroIsNotAValidOwner(); }
        return sp.balance[owner];
    }

    function ownerOf(uint256 tokenId) public view virtual returns (address) {
        SupplyPosition storage sp = supplyPositionStorage();

        address owner = sp.owner[tokenId];
        if (owner == address(0)) { revert ERC721InvalidTokenId(); }
        return owner;
    }

    function name() public view virtual returns (string memory) {
        SupplyPosition storage sp = supplyPositionStorage();

        return sp.name;
    }

    function symbol() public view virtual returns (string memory) {
        SupplyPosition storage sp = supplyPositionStorage();

        return sp.symbol;
    }

    function approve(address to, uint256 tokenId) public virtual {
        address owner = ownerOf(tokenId);
        if (to == owner) { revert ERC721ApprovalToCurrentOwner(); }
        if (msg.sender != owner && !isApprovedForAll(owner, msg.sender)) {
            revert ERC721CallerIsNotOwnerNorApprovedForAll(); 
        }

        _approve(to, tokenId);
    }

    function getApproved(uint256 tokenId) public view virtual returns (address) {
        SupplyPosition storage sp = supplyPositionStorage();

        if (!_exists(tokenId)) { revert ERC721InvalidTokenId(); }

        return sp.tokenApproval[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public virtual {
        _setApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address owner, address operator) public view virtual returns (bool) {
        SupplyPosition storage sp = supplyPositionStorage();

        return sp.operatorApproval[owner][operator];
    }

    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual {
        if (!_isApprovedOrOwner(msg.sender, tokenId)) { revert ERC721CallerIsNotOwnerNorApproved(); }

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public virtual {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) public virtual {
        if (!_isApprovedOrOwner(msg.sender, tokenId)) { revert ERC721CallerIsNotOwnerNorApproved(); }
        _safeTransfer(from, to, tokenId, data);
    }

    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _transfer(from, to, tokenId);
        if (!_checkOnERC721Received(from, to, tokenId, data)) { 
            revert ERC721TransferToNonERC721ReceiverImplementer(); 
        }
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        SupplyPosition storage sp = supplyPositionStorage();

        return sp.owner[tokenId] != address(0);
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner || isApprovedForAll(owner, spender) || getApproved(tokenId) == spender);
    }

    function _safeMint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    function _safeMint(
        address to,
        uint256 tokenId,
        bytes memory data
    ) internal virtual {
        _mint(to, tokenId);
        if (!_checkOnERC721Received(address(0), to, tokenId, data)) { 
            revert ERC721TransferToNonERC721ReceiverImplementer(); 
        }
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        SupplyPosition storage sp = supplyPositionStorage();

        if (to == address(0)) { revert ERC721MintToTheZeroAddress(); }
        if (_exists(tokenId)) { revert ERC721TokenAlreadyMinted(); }

        sp.balance[to] += 1;
        sp.owner[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    function _burn(uint256 tokenId) internal virtual {
        SupplyPosition storage sp = supplyPositionStorage();

        address owner = ownerOf(tokenId);

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
    ) internal virtual {
        SupplyPosition storage sp = supplyPositionStorage();

        if (ownerOf(tokenId) != from) { revert ERC721TransferToIncorrectOwner(); }
        if (to == address(0)) { revert ERC721TransferToTheZeroAddress(); }

        // Clear approvals from the previous owner
        _approve(address(0), tokenId);

        sp.balance[from] -= 1;
        sp.balance[to] += 1;
        sp.owner[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    function _approve(address to, uint256 tokenId) internal virtual {
        SupplyPosition storage sp = supplyPositionStorage();

        sp.tokenApproval[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    function _setApprovalForAll(
        address owner,
        address operator,
        bool approved
    ) internal virtual {
        SupplyPosition storage sp = supplyPositionStorage();

        if (owner == operator) { revert ERC721ApproveToCaller(); }
        sp.operatorApproval[owner][operator] = approved;
        emit ApprovalForAll(owner, operator, approved);
    }

    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory data
    ) private returns (bool) {
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