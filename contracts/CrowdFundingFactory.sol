// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import './CrowdFundingCampaign.sol';

/**
 * @title 工厂合约
 * @notice 使用工厂模式来部署多个众筹合约实例
 */
contract CrowdFundingFactory {
  CrowdFundingCampaign[] campaigns;

  mapping(address => uint256[]) public userCampaigns;

  event CampaignCreated(
    address indexed creator,
    address indexed campaign,
    string name,
    uint256 goal,
    uint256 deadline
  );

  // 创建新的众筹
  function createCampaign(
    string memory _name,
    uint256 _goal,
    uint256 _durationInDays
  ) external returns (address) {
    CrowdFundingCampaign campaign = new CrowdFundingCampaign(msg.sender, _name, _goal, _durationInDays);

    campaigns.push(campaign);
    userCampaigns[msg.sender].push(campaigns.length - 1);

    emit CampaignCreated(
      msg.sender,
      address(campaign),
      _name,
      _goal,
      _durationInDays
    );

    return address(campaign);
  }

  // 获取所有的活动地址
  function getCampaigns() external view returns (address[] memory) {
    uint256 size = campaigns.length;
    address[] memory addresses = new address[](size);
    for (uint256 i = 0; i < size; i++) {
      addresses[i] = address(campaigns[i]);
    }
    return addresses;
  }

  // 获取指定用户的活动地址
  function getUserCampaigns(address user) external view returns (address[] memory) {
    uint256[] memory indexes = userCampaigns[user];
    uint256 size = indexes.length;
    address[] memory addresses = new address[](size);
    for (uint256 i; i < size; i++) {
      addresses[i] = address(campaigns[indexes[i]]);
    }
    return addresses;
  }

  function getCampaignCount() external view returns (uint256) {
    return campaigns.length;
  }
}