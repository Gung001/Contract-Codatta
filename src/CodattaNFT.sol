// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";


contract CodattaNFT is Initializable, ERC721Upgradeable, OwnableUpgradeable, UUPSUpgradeable, ReentrancyGuardUpgradeable {

    uint256 immutable MAX_SUPPLY = 1000;
    address public signer;
    
    string private _defaultURI;
    uint256 private _currentTokenId;
    bytes32 internal DOMAIN_SEPARATOR;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address initialOwner, address initialSigner) initializer public {
        __ERC721_init("CodattaNFT", "CD");
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();

        signer = initialSigner;
        DOMAIN_SEPARATOR = _computeDomainSeparator();
    }

    function mint(bytes32 _r, bytes32 _s, uint8 _v) public nonReentrant {

        require(balanceOf(msg.sender) == 0, "CodattaNFT: Own only one token");
        require(_currentTokenId < MAX_SUPPLY, "CodattaNFT: Reach the max supply");
        require(_verifySigner(msg.sender, _v, _r, _s) == signer, "CodattaNFT: Invalid signer");

        _currentTokenId++;

        _mint(msg.sender, _currentTokenId);
    }

    function _verifySigner(
        address recipient,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    ) internal view returns (address _signer) {
        _signer = ECDSA.recover(
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    keccak256(
                        abi.encode(
                            keccak256("mint(address recipient)"),
                            recipient
                        )
                    )
                )
            ),
            _v,
            _r,
            _s
        );
    }

    function setSigner(address _signer) external onlyOwner {
        require(_signer != address(0), "CodattaNFT: Zero address");
        signer = _signer;
    }

    function setDefaultURI(string calldata uri) public onlyOwner {
        _defaultURI = uri;
    }
    
    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overridden in child contracts.
     */
    function _baseURI() internal view override returns (string memory) {
        return _defaultURI;
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        onlyOwner
        override
    {}

    function transferFrom(address from, address to, uint256 tokenId) public override  {
        require(false, "CodattaNFT: Soul Bound Token");
        super.transferFrom(from, to, tokenId);
    }

    function _computeDomainSeparator() internal view returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes("CodattaNFT")),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }
}