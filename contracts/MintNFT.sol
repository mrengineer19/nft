pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MintNFT is ERC721Enumerable {
  
  constructor() ERC721('Master NFT', 'MNFT') {}

  struct MasterTokens {
    uint256 id;
    string name;
    string description;
    string tokenURI;
  }

  event Created(uint256 id, string name, string description, string tokenURI);

  uint256 public tokenCount = 0;

  mapping(uint256 => MasterTokens) public tokens;

  // Optional mapping for token URIs
  mapping (uint256 => string) private _tokenURIs;

  function createToken(string memory name, string memory description, string memory tokenUri) 
  public 
  returns (uint256)
  {
    require(bytes(name).length > 0);
    require(bytes(description).length > 0);
    require(bytes(tokenUri).length > 0);

    tokenCount++;

    tokens[tokenCount] = MasterTokens(tokenCount, name, description, tokenUri);
    _mint(msg.sender, tokenCount);
    _setTokenURI(tokenCount, tokenUri);

    emit Created(tokenCount, name, description, tokenUri);

    return tokenCount;
  }

  /**
    * @dev See {IERC721Metadata-tokenURI}.
    */
  function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
      require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

      string memory _tokenURI = _tokenURIs[tokenId];
      string memory base = _baseURI();

      // If there is no base URI, return the token URI.
      if (bytes(base).length == 0) {
          return _tokenURI;
      }
      // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
      if (bytes(_tokenURI).length > 0) {
          return string(abi.encodePacked(base, _tokenURI));
      }

      return super.tokenURI(tokenId);
  }

  /**
    * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
    *
    * Requirements:
    *
    * - `tokenId` must exist.
    */
  function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
      require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
      _tokenURIs[tokenId] = _tokenURI;
  }
}
