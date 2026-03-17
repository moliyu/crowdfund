// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract CrowdFundingCampaign {
  enum State {
    Preparing,
    Active,
    Success,
    Failed,
    Close
  }

  State public state;

  address public immutable owner;
  string public name;
  uint256 public immutable goal;
  uint256 public immutable deadline;
  uint256 public totalRaised;

  address[] public contributors;
  mapping(address => uint256) public contributions;

  event StateChanged(State oldState, State newState);
  event Contribution(address sender, uint256 value);
  event WithDrawal(address to, uint256 amount);
  event Refund(address to, uint256 amount);

  modifier onlyOwner {
    require(msg.sender == owner, "CrowdfundingCampaign: not owner");
    _;
  }

  modifier inState(State _state) {
    require(_state == state, "CrowdfundingCampaign: invalid state");
    _;
  }

  modifier notExpired() {
    require(block.timestamp < deadline);
    _;
  }

  constructor(
    address _owner,
    string memory _name,
    uint256 _goal,
    uint256 _durationInDays
  ) {
    require(_owner != address(0), 'CrowdfundingCampaign: invalid owner');
    require(bytes(_name).length > 0, 'CrowdfundingCampaign: name cannot be empty');
    require(_goal > 0, "CrowdfundingCampaign: goal must be positive");
    require(_durationInDays > 0 && _durationInDays <= 90, "CrowdfundingCampaign: invalid duration");

    owner = _owner;
    name = _name;
    goal = _goal;
    deadline = block.timestamp + (_durationInDays * 1 days);

    state = State.Preparing;
  }

  // 活动启动
  function start() external onlyOwner inState(State.Preparing) {
    state = State.Active;
    emit StateChanged(State.Preparing, State.Active);
  }

  // 贡献资金
  function contribute() external payable inState(State.Active) notExpired {
    require(msg.value > 0, "value must be positive");
    if (contributions[msg.sender] == 0) {
      contributors.push(msg.sender);
    }

    contributions[msg.sender] += msg.value;
    totalRaised += msg.value;
    emit Contribution(msg.sender, msg.value);

    if (totalRaised >= goal) {
      state = State.Success;
      emit StateChanged(State.Active, State.Success);
    }
  }

  // 完成活动函数
  // 截止时间后调用
  function finalize() external inState(State.Active) {
    require(block.timestamp >= deadline, "campaign not end");

    State oldState = state;
    if (totalRaised < goal) {
      state = State.Failed;
    } else {
      state = State.Success;
    }

    emit StateChanged(oldState, state);
  }

  // 提取资金
  // 必须创建者并且活动已结束才可以调用
  function withDraw() external inState(State.Success) onlyOwner {
    state = State.Close;

    uint256 amount = address(this).balance;

    (bool success, ) = owner.call{ value: amount }("");
    require(success, "with draw error");

    emit WithDrawal(owner, amount);
    emit StateChanged(State.Success, State.Close);
  }

  // 退款
  // 活动结束每个人可以申请退款
  // 一般不在合约中循环调用自动退款 gas
  function refund() external inState(State.Failed) {
    uint256 amount = contributions[msg.sender];
    require(amount > 0, "no contribution to refund");

    contributions[msg.sender] = 0;

    (bool success, ) = address(msg.sender).call{ value: amount }("");
    require(success, "refund err");

    emit Refund(msg.sender, amount);
  }

  // 获取所有贡献者地址
  function getContributors() external view returns (address[] memory){
    return contributors;
  }

  function isActive() external view returns (bool) {
    return state == State.Active;
  }

  function getProgress() external view returns (uint256) {
    if (goal == 0) return 0;

    uint256 progress = totalRaised * 100 / goal;
    return progress > 100 ? 100 : progress;
  }
}