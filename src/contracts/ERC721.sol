// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './ERC165.sol';
import './interfaces/IERC721.sol';

/*
    building out the minting function:
    a. nft to point to an address
    b. keep track of the token ids
    c. keep track of token owner addresses to token ids
    d. keep track of how many tokens an owner address has
    e. create an event that emits a transfer log -
    contract address, where it is being minted to, the id
*/
contract ERC721 is ERC165, IERC721 {
    // mapping from token id to the owner
    mapping(uint256 => address) private _tokenOwner;

    // mapping from owner to number of owned tokens
    mapping(address => uint256) private _OwnedTokensCount;

    // mapping from token id to approved addresses
    mapping(uint256 => address) private _tokenApprovals;

    constructor() {
        _registerInterface(bytes4(keccak256('balanceOf(bytes4)') ^ 
        keccak256('ownerOf(bytes4)') ^ keccak256('transferFrom(bytes4)')));
    }
    
    function balanceOf(address _owner) public override view returns(uint256) {
        require(_owner != address(0), 'Owner query for non-existent token');
        return _OwnedTokensCount[_owner];
    }

    function ownerOf(uint256 _tokenId) public override view returns(address) {
        address owner = _tokenOwner[_tokenId];
        require(owner != address(0), 'Owner query for non-existent token');
        return owner;
    }

    function _exists(uint256 tokenId) internal view returns(bool) {
        // setting the address of nft owner to check mapping
        // of the address from tokenOwner at the tokenId
        address owner = _tokenOwner[tokenId];
        // return truthiness the address is not zero
        return owner != address(0);
    }

    function _mint(address to, uint256 tokenId) internal virtual {
        // requires that the address is not zero
        require(to != address(0), 'ERC721: minting to the zero address');
        // requires that the token does not already exist
        require(!_exists(tokenId), 'ERC721: token already minted');
        // adding a new address with a token id for minting
        _tokenOwner[tokenId] = to;
        // keeping track of each address that is minting and adding one to the count
        _OwnedTokensCount[to] += 1;

        emit Transfer(address(0), to, tokenId);
    }

    function _transferFrom(address _from, address _to, uint256 _tokenId) internal {
        require(_to != address(0), 'Error - ERC721 Transfer to the zero address');
        require(ownerOf(_tokenId) == _from, 'Trying to transfer a token the address does not own');

        _OwnedTokensCount[_from] -= 1;
        _OwnedTokensCount[_to] += 1;
        _tokenOwner[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) override public {
        require(isApprovedOrOwner(msg.sender, _tokenId));
        _transferFrom(_from, _to, _tokenId);
    }

    // require that the person approving is the owner
    // approve an address to a token (tokenId)
    // require that cant approve sending tokens of the owner to himself (current caller)
    // update the map of the approval addresses
    function approve(address _to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(_to != owner, 'Error - approval to current owner');
        require(msg.sender == owner, 'Current caller is not the owner of the token');
        _tokenApprovals[tokenId] = _to;

        emit Approval(owner, _to, tokenId);
    }

    function isApprovedOrOwner(address spender, uint256 tokenId) internal view returns(bool) {
        require(_exists(tokenId), 'token does not exist');
        address owner = ownerOf(tokenId);
        return (spender == owner);
    }
}