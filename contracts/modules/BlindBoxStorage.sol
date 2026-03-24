// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

library BlindBoxStorage {
    struct BlindBox {
        bool purchased;
        bool revealed;
        uint256 purchaseTime;
        uint256 revealTime;
    }

    function createBlindBox() internal view returns (BlindBox memory) {
        return
            BlindBox({
                purchased: true,
                revealed: false,
                purchaseTime: block.timestamp,
                revealTime: 0
            });
    }

    function markAsRevealed(BlindBox storage box) internal {
        box.revealed = true;
        box.revealTime = block.timestamp;
    }

    function getBoxStatus(
        BlindBox storage box
    )
        internal
        view
        returns (
            bool purchased,
            bool revealed,
            uint256 purchaseTime,
            uint256 revealTime
        )
    {
        return (box.purchased, box.revealed, box.purchaseTime, box.revealTime);
    }
}
