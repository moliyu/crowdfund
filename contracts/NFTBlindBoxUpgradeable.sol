// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./interfaces/IVRFHandler.sol";
import "./libiraries/RarityLibrary.sol";
import "./modules/BlindBoxStorage.sol";
import "./modules/SaleManager.sol";

contract NFTBlindBoxUpgradeable is
    Initializable,
    ERC721Upgradeable,
    OwnableUpgradeable,
    ReentrancyGuard,
    UUPSUpgradeable,
    IVRFCallback
{
    using RarityLibrary for RarityLibrary.Rarity;
    using BlindBoxStorage for BlindBoxStorage.BlindBox;

    event BoxPurchased(address indexed buyer, uint256 indexed tokenId);
    event BoxRevealed(uint256 indexed tokenId, RarityLibrary.Rarity rarity);
    event RarityAssigned(uint256 indexed tokenId, RarityLibrary.Rarity rarity);

    uint256 maxSupply;
    SaleManager public saleManager;
    VRFHandler public vrfHandler;

    function initialize(
        string memory name,
        string memory symbol,
        uint256 _maxSupply,
        uint256,
        address saleManagerAddress,
        address vrfhanlderAddress,
        string memory baseURI
    ) public initializer {
        __ERC721_init(name, symbol);
        __Ownable_init(msg.sender);
        saleManager = SaleManager(saleManagerAddress);
    }
}
