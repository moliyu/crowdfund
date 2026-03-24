// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";
import "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import "../interfaces/IVRFHandler.sol";

contract VRFHandler is Initializable, OwnableUpgradeable, IVRFHandler {
    IVRFCoordinatorV2Plus private vrfCoordinator;
    bytes32 private keyHash;
    uint256 private subscriptionId;
    uint32 private callbackGasLimit;
    uint16 private requestConfirmations;
    uint32 private numWords;
    bool private nativePayment;

    mapping(uint256 => uint256) private requestIdToTokenId;
    mapping(uint256 => address) private requestIdToCallback;

    event VRFConfigUpdated(
        address indexed coordinator,
        bytes32 keyHash,
        uint256 subscriptionId
    );

    error OnlyCoordinator;
    error InvalidRequestId;

    modifier onlyCoordinator() {
        if (msg.sender != address(vrfCoordinator)) {
            revert OnlyCoordinator();
        }
        _;
    }

    function initialize(
        address _vrfCoordinator,
        bytes32 _keyHash,
        uint256 _subscriptionId,
        uint32 _callbackGasLimit,
        uint16 _requestConfirmations,
        bool _nativePayment
    ) public initializer {
        __Ownable_init(msg.sender);
        vrfCoordinator = IVRFCoordinatorV2Plus(_vrfCoordinator);
        keyHash = _keyHash;
        subscriptionId = _subscriptionId;
        callbackGasLimit = _callbackGasLimit;
        requestConfirmations = _requestConfirmations;
        numWords = 1;
        nativePayment = _nativePayment;
    }

    function requestRandomness(
        tokenId,
        callbackContract
    ) external view returns (uint256) {
        VRFV2PlusClient.RandomWordsRequest memory req = VRFV2PlusClient
            .RandomWordsRequest({
                keyHash: keyHash,
                subId: subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: nativePayment})
                )
            });
    
        requestId
    }
}
