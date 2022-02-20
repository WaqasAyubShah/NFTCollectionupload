// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NftCollection is ERC721Enumerable, Ownable {
  using Strings for uint256;

  string public baseURI;
  string public baseImageURI;
  string public baseExtension = ".json";
  string public baseImageExtension= ".png";
  uint256 public cost = 0.01 ether;
  uint256 public maxSupply = 50;
  uint256 public maxMintAmount = 50;
  bool public paused = false;
  mapping(address => bool) public whitelisted;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    string memory _initImageURI
  ) ERC721(_name, _symbol) {
    setBaseImageURI(_initImageURI);
    setBaseURI(_initBaseURI);
    mint(msg.sender, 50);
  }

  function setCost(uint256 _newCost) public onlyOwner() {
    cost = _newCost;
  }

  function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner() {
    maxMintAmount = _newmaxMintAmount;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseImageURI(string memory _newImageBaseURI) public onlyOwner {
    baseImageURI = _newImageBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function getBaseImageURI() internal view virtual returns (string memory) {
    return baseImageURI;
  }

  function getImageUriBasedOnToken(uint256 tokenId)
    public
    view
    virtual
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token image"
    );

    string memory currentBaseImageURI = getBaseImageURI();
    return bytes(currentBaseImageURI).length > 0
        ? string(abi.encodePacked(currentBaseImageURI, tokenId.toString(), baseImageExtension))
        : "";
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function mint(address _to, uint256 _mintAmount) public payable {
    uint256 supply = totalSupply();
    require(!paused);
    require(_mintAmount > 0);
    require(_mintAmount <= maxMintAmount);
    require(supply + _mintAmount <= maxSupply);

    if (msg.sender != owner()) {
        if(whitelisted[msg.sender] != true) {
          require(msg.value >= cost * _mintAmount);
        }
    }

    for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(_to, supply + i);
    }
  }

  function getAllNftTokensFromWalletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
 
 function whitelistUser(address _user) public onlyOwner {
    whitelisted[_user] = true;
  }
 
  function removeWhitelistUser(address _user) public onlyOwner {
    whitelisted[_user] = false;
  }

  function withdraw() public payable onlyOwner {
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success);
  }
}
