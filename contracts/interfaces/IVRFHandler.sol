// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

interface IVRFHandler {
  event RandomnessRequested(uint256 indexed requestId, uint256 indexed tokenId);
  event RandomnessFulfilled(uint256 indexed requestId, uint256 indexed tokenId);

  function requestRandomness(uint256 tokenId, address callbackContract) external view returns (uint256 requestId);

  function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external;

  function getTokenIdByRequestId(uint256 requestId) external view returns (uint256 tokenId);

  function getCallbackContractByRequestId(uint256 requestId) external view returns (address);
}

interface IVRFCallback {
  function handleVRFCallback(uint256 requestId, uint256 tokenId, uint256 randomness) external;
}