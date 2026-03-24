// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts-upgradeable/proxy/utils/initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract SaleManager is Initializable, OwnableUpgradeable {
    enum SalePhase {
        NotStarted,
        WhiteList,
        Public
    }

    bool public saleActive;
    SalePhase public currentPhase;
    uint256 public price;
    uint256 public maxPerWallet;
    uint256 public constant whiteListMaxMint = 3;

    mapping(address => bool) whiteList;
    mapping(address => uint256) whiteListMinted;

    event SalePhaseChanged(SalePhase newPhase);
    event PriceUpdated(uint256 newPrice);
    event MaxPerWalletUpdated(uint256 newMax);
    event WhitelistAdded(address[] addresses);
    event WhitelistRemoved(address[] addresses);
    event WhitelistMinted(address indexed user, uint256 count);

    function initialize(
        uint256 _price,
        uint256 _maxPerWallet
    ) public initializer {
        __Ownable_init(msg.sender);
        price = _price;
        maxPerWallet = _maxPerWallet;
        currentPhase = SalePhase.NotStarted;
        saleActive = false;
    }

    function setSaleActive(bool _active) external onlyOwner {
        saleActive = _active;
    }

    function setSalePhase(SalePhase _salePhase) external onlyOwner {
        currentPhase = _salePhase;
        saleActive = (_salePhase != SalePhase.NotStarted);
        emit SalePhaseChanged(_salePhase);
    }

    function setPrice(uint256 _price) external onlyOwner {
        price = _price;
        emit PriceUpdated(_price);
    }

    function setMaxPerWallet(uint256 _max) external onlyOwner {
        maxPerWallet = _max;
        emit MaxPerWalletUpdated(_max);
    }

    function addToWhiteList(address[] memory addresses) external onlyOwner {
        uint256 size = addresses.length;
        for (uint256 i = 0; i < size; i++) {
            whiteList[addresses[i]] = true;
        }

        emit WhitelistAdded(addresses);
    }

    function removeFormWhiteList(
        address[] memory addresses
    ) external onlyOwner {
        uint256 size = addresses.length;
        for (uint256 i = 0; i < size; i++) {
            whiteList[addresses[i]] = false;
        }

        emit WhitelistRemoved(addresses);
    }

    function canPurchase(
        address user,
        uint256 userBalance,
        uint256 payment
    ) external view returns (bool, string memory) {
        if (!saleActive) {
            return (false, "Sale not active");
        }
        if (payment < price) {
            return (false, "Insufficient payment");
        }
        if (userBalance > maxPerWallet) {
            return (false, "Max per wallet reached");
        }
        if (currentPhase == SalePhase.WhiteList) {
            if (!whiteList[user]) {
                return (false, "Not whiteList");
            }
            if (whiteListMinted[user] > maxPerWallet) {
                return (false, "Max Per wallet");
            }
        }
        return (true, "");
    }

    function recordWhiteListPurchase(address user) external {
        if (currentPhase == SalePhase.WhiteList) {
            whiteListMinted[user]++;
            emit WhitelistMinted(user, whiteListMinted[user]);
        }
    }
}
