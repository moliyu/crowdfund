// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract CrowdFoundingCompaign {
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
  mapping(address => uint256) contributions;

  event StateChanged(State oldState, State newState);
  event Contribution(address sender, uint256 value);

  modifier onlyOwner {
    require(msg.sender == owner, "CrowdFoundingCompaign: not owner");
    _;
  }

  modifier inState(State _state) {
    require(_state == state, "CrowdFoundingCompaign: invalid state");
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
    require(_owner != address(0), 'CrowdFoundingCompaign: invalid owner');
    require(bytes(_name).length > 0, 'CrowdFoundingCompaign: name cannot be empty');
    require(_goal > 0, "CrowdFoundingCompagin: goal must be positive");
    require(_durationInDays > 0 && _durationInDays <= 90, "CrowdFoundingCompaign: invalid duration");

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
}