// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

// 稀有度管理库
library RarityLibrary {
    uint256 public constant COMMON_PROBABILITY = 6000; // 60%
    uint256 public constant RARE_PROBABILITY = 2500; // 25%
    uint256 public constant EPIC_PROBABILITY = 1200; // 12%
    uint256 public constant LEGENDARY_PROBABILITY = 300; // 3%

    enum Rarity {
        Common,
        Rare,
        Epic,
        Legendary
    }

    error InvalidRandomness();

    function assignRarity(
        uint256 randomness
    ) internal pure returns (Rarity rarity) {
        uint256 randomValue = randomness % 10000;

        if (randomValue < LEGENDARY_PROBABILITY) {
            return Rarity.Legendary;
        } else if (randomValue < EPIC_PROBABILITY + LEGENDARY_PROBABILITY) {
            return Rarity.Epic;
        } else if (
            randomValue <
            EPIC_PROBABILITY + LEGENDARY_PROBABILITY + COMMON_PROBABILITY
        ) {
            return Rarity.Rare;
        } else {
            return Rarity.Common;
        }
    }

    function rarityToSTring(Rarity rarity) internal pure returns (string memory) {
      if (rarity == Rarity.Common) return "common";
      if (rarity == Rarity.Rare) return "rare"
      if (rarity == Rarity.Epic) return "epic"
      if (rarity == Rarity.Legendary) return "legendary"
      return "unkown";
    }

    function getProbability(Rarity rarity) internal pure returns (uint256) {
      if (rarity == Rarity.Common) return COMMON_PROBABILITY;
      if (rarity == Rarity.Rare) return RARE_PROBABILITY;
      if (rarity == Rarity.Epic) return EPIC_PROBABILITY;
      if (rarity == Rarity.Legendary) return LEGENDARY_PROBABILITY;
    }

    function validprobabilities() internal pure returns (bool) {
      return COMMON_PROBABILITY + EPIC_PROBABILITY + RARE_PROBABILITY +LEGENDARY_PROBABILITY == 10000
    }
}
