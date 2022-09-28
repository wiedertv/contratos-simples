// SPDX-License-Identifier: MIT


/*
                                                                                                                                                                                                            
                                                                                                    
                                 &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&#           
                               &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&        
                            &&&&& &&&&                                              &&&&&&&&        
                         &&&&&/   &&&&                                              &&&&&&&&        
                      &&&&&&      &&&&                                              &&&&&&&&        
                   &&&&&&         &&&&                                              &&&&&&&&        
                 &&&&&            &&&&                                              &&&&&&&&        
              &&&&&               &&&&                                              &&&&&&&&        
           &&&&&&                 &&&&                                              &&&&&&&&        
        &&&&&&                    &&&&                                              &&&&&&&&        
       &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&                                              &&&&&&&&        
       &&&&                                                                         &&&&&&&&        
       &&&&                                                                         &&&&&&&&        
       &&&&                                                                         &&&&&&&&        
       &&&&                                                                         &&&&&&&&        
       &&&&                                                                         &&&&&&&&        
       &&&&                      &&&&&&                  &&&&&&                     &&&&&&&&        
       &&&&                      &&&&&&                  &&&&&&                     &&&&&&&&        
       &&&&                      &&&&&&                  &&&&&&                     &&&&&&&&        
       &&&&                      &&&&&&                  &&&&&&                     &&&&&&&&        
       &&&&                      &&&&&&                  &&&&&&                     &&&&&&&&        
       &&&&                      &&&&&&                  &&&&&&                     &&&&&&&&        
       &&&&                      &&&&&&                  &&&&&&                     &&&&&&&&        
       &&&&                .&&&&&&&&&&&                  &&&&&&&&&&&&               &&&&&&&&        
       &&&&                                                                         &&&&&&&&        
       &&&&                                                                         &&&&&&&&        
       &&&&                                                                         &&&&&&&&        
       &&&&                                                                         &&&&&&&&        
       &&&&                                                                         &&&&&&&&        
       &&&&                       &&&&                                              &&&&&&&&        
       &&&&                           &&&&&&&&&&&&&&&&&&&&                          &&&&&&&&        
       &&&&                           &&&&&&&&&&&&&&&&&&&&                          &&&&&&&&        
       &&&&                                                                         &&&&&&&&        
       &&&&                                                                         &&&&&&&&        
       &&&&                                                                         &&&&&&&&        
       &&&&                                                                         &&&&&&&&        
       &&&&                                                                         &&&&&&&&        
       &&&&                                                                         &&&&&&&&        
       &&&&                                                                         &&&&&&&&        
       &&&&                                                                         &&&&&&&&        
       &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&        
       &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&WIEDERTV&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&        
          &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&        
                                                                                                    
                                                                                                                                                                                                        
*/

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract NSUJPG1155Contract is ERC1155, AccessControl, ERC1155Burnable, ERC1155Supply, ERC2981 {
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");
    bytes32 public constant AIRDROP_ROLE = keccak256("AIRDROP_ROLE");
    uint256 private idToMint;
    uint256 private costToMint;
    bool private isWhitelist;
    bool private isSaleActive;
    using Strings for uint256;
    string public contractURI;
    string public _uri;
    string public name;
    string public symbol;
    mapping(address => bool) public whitelisted;

     constructor(string memory initialContractURI, string memory _name, string memory _symbol, string memory uri_, uint96 _royaltyFeesInBips)
        ERC1155(_uri)
    {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MODERATOR_ROLE, msg.sender);
        setRoyaltyInfo(msg.sender, _royaltyFeesInBips);
        _uri = uri_; 
        symbol= _symbol;
        name= _name;
        contractURI = initialContractURI;
        isWhitelist=true;
        isSaleActive= false;
    }

    function setURI(string memory newuri) public onlyRole(MODERATOR_ROLE) {
        _uri= newuri;
        _setURI(newuri);
    }

    function mint(address account, uint256 amount)
        public
        payable
    {
        require(msg.value >= costToMint, "Monto Insuficiente");
        require(isSaleActive, "La venta no esta activa");
        if(isWhitelist){
            require(whitelisted[msg.sender], "No tienes whitelist");
        }
            _mint(account, idToMint, amount, '');
    }

    function create(uint256 amount, uint256 _tokenId) public onlyRole(MODERATOR_ROLE)
    {
        _mint(msg.sender, _tokenId, amount, '');
    }

    function setTokenToMint(uint256 _idToMint) public onlyRole(MODERATOR_ROLE){
        idToMint = _idToMint;
    }

    function setCostToMint(uint256 _costToMint) public onlyRole(MODERATOR_ROLE){
        costToMint = _costToMint;
    }

    function setContractURI(string memory newContractURI) public onlyRole(MODERATOR_ROLE) {
        contractURI = newContractURI;
    }

    function addToWhitelist(address _add) public onlyRole(MODERATOR_ROLE) {
        whitelisted[_add] = true;
    }

    function batchAddToWhitelist(address[] memory _add) public onlyRole(MODERATOR_ROLE) {
        for (uint256 i = 0 ; i < _add.length ; i++){
            whitelisted[_add[i]] = true;
        }
    }

    function setWhitelistPhase() public returns (bool) {
        isWhitelist = !isWhitelist;
        return isWhitelist;
    }
    
    function removeToWhitelist(address _remove) public onlyRole(MODERATOR_ROLE) {
        whitelisted[_remove] = false;
    }

    function batchRemoveToWhitelist(address[] memory _remove) public onlyRole(MODERATOR_ROLE) {
        for (uint256 i = 0 ; i < _remove.length ; i++){
            whitelisted[_remove[i]] = false;
        }
    }

    function airdrop( uint256 _quantity, address _to, uint256 _token) public onlyRole(AIRDROP_ROLE) {
            _mint(_to, _token, _quantity, "");
    }
    
    function batchAirdrop( uint256[] memory _quantity, address[] memory _to, uint256 _token) public onlyRole(AIRDROP_ROLE) {
        require( _quantity.length == _to.length, 'Quantity array must have exact lenght than _to array');
        for (uint256 i = 0; i < _quantity.length ; i++){
            _mint(_to[i], _token, _quantity[i], "");
        }
    }

    function setRoyaltyInfo(address _receiver, uint96 _royaltyFeesInBips) public onlyRole(MODERATOR_ROLE) {
        _setDefaultRoyalty(_receiver, _royaltyFeesInBips);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function withdraw(address _collaborator) public onlyRole(MODERATOR_ROLE){
        address payable to = payable(msg.sender);
        address payable collaborator = payable(_collaborator);
        to.transfer(getBalance()/2);
        collaborator.transfer(getBalance()/2);
    }

    function setTokenRoyalty(uint256 tokenId , address receiver, uint96 feeNumerato) public onlyRole(MODERATOR_ROLE){
        _setTokenRoyalty(tokenId, receiver, feeNumerato);
    }

    function resetTokenRoyalty(uint256 tokenId)public onlyRole(MODERATOR_ROLE) {
        _resetTokenRoyalty(tokenId);
    }


    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        override(ERC1155, ERC1155Supply)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function uri(uint256 tokenId) public view override returns (string memory)  
    {
        return bytes(_uri).length > 0 ? string(abi.encodePacked(_uri, tokenId.toString(), ".json")) : "";
    }


    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

}
