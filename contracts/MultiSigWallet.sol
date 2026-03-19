// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

contract MultiSigWallet {
    event OwnerAdded(address owner);
    event OwnerRemoved(address owner);
    event ThresholdChanged(uint256 newThreshold);
    event SubmitTransaction(
        uint256 txIndex,
        address to,
        uint256 value,
        bytes data
    );
    event ConfirmTransaction(address sender, uint256 txIndex);
    event RevokeConfirmation(address sender, uint256 txIndex);
    event ExecuteTransaction(uint256 txIndex);
    event Deposit(address sender, uint256 value);

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public numConfirmationsReqeust;

    mapping(uint256 => mapping(address => bool)) isConfirmed;

    struct Transaction {
        address to;
        uint256 value;
        bool executed;
        bytes data;
        uint256 numConfirmations;
    }

    Transaction[] public transactions;

    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier txExists(uint256 txIndex) {
        require(txIndex < transactions.length, "transaction not exist");
        _;
    }

    modifier notExecuted(uint256 txIndex) {
        require(!transactions[txIndex].executed, "transaction has exectued");
        _;
    }

    modifier notConfirmed(uint256 txIndex) {
        require(
            !isConfirmed[txIndex][msg.sender],
            "transaction has been confirmed"
        );
        _;
    }

    constructor(address[] memory _owners, uint256 _numConfirmationsRequest) {
        require(_owners.length > 0, "Owners required");
        require(
            _numConfirmationsRequest > 0 &&
                _numConfirmationsRequest < _owners.length,
            "not a valid number"
        );
        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "zero address");
            require(!isOwner[owner], "not a unique address");

            isOwner[owner] = true;
            owners.push(owner);
        }
        numConfirmationsReqeust = _numConfirmationsRequest;
    }

    function addOwner(address newOwener) external onlyOwner {
        require(newOwener != address(0), "zero address");
        require(!isOwner[newOwener], "have added");
        isOwner[newOwener] = true;
        owners.push(newOwener);

        emit OwnerAdded(newOwener);
    }

    function removeOwner(address owner) external onlyOwner {
        require(isOwner[owner], "not a owner");
        require(
            owners.length - 1 >= numConfirmationsReqeust,
            "cannot remove owner"
        );

        isOwner[owner] = false;
        for (uint256 i = 0; i < owners.length; i++) {
            address _owner = owners[i];
            if (_owner == owner) {
                owners[i] = owners[owners.length - 1];
                owners.pop();
                break;
            }
        }

        emit OwnerRemoved(owner);
    }

    function changeThreshold(uint256 newThreshold) external onlyOwner {
        require(
            newThreshold > 0 && newThreshold < owners.length,
            "invalid threshold"
        );
        numConfirmationsReqeust = newThreshold;

        emit ThresholdChanged(newThreshold);
    }

    function submitTransaction(
        address to,
        uint256 value,
        bytes memory data
    ) external onlyOwner {
        uint txIndex = transactions.length;

        transactions.push(
            Transaction({
                to: to,
                value: value,
                data: data,
                executed: false,
                numConfirmations: 0
            })
        );

        emit SubmitTransaction(txIndex, to, value, data);
    }

    function getTransaction(
        uint256 txIndex
    ) external view txExists(txIndex) returns (Transaction memory) {
        return transactions[txIndex];
    }

    function getTransactionCount() external view returns (uint256) {
        return transactions.length;
    }

    function confirmTransaction(
        uint256 txIndex
    )
        external
        onlyOwner
        txExists(txIndex)
        notExecuted(txIndex)
        notConfirmed(txIndex)
    {
        Transaction storage transaction = transactions[txIndex];
        isConfirmed[txIndex][msg.sender] = true;
        transaction.numConfirmations += 1;

        emit ConfirmTransaction(msg.sender, txIndex);
    }

    function revokeConfirmation(
        uint256 txIndex
    ) external onlyOwner notExecuted(txIndex) {
        require(isConfirmed[txIndex][msg.sender], "transaction not confirmed");

        Transaction storage transaction = transactions[txIndex];
        isConfirmed[txIndex][msg.sender] = false;
        transaction.numConfirmations -= 1;

        emit RevokeConfirmation(msg.sender, txIndex);
    }

    function executeTransaction(
        uint256 txIndex
    ) external onlyOwner notExecuted(txIndex) {
        Transaction storage transaction = transactions[txIndex];

        require(
            transaction.numConfirmations >= numConfirmationsReqeust,
            "not enough confirmations"
        );
        transaction.executed = true;
        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, "transaction err");

        emit ExecuteTransaction(txIndex);
    }

    function getOwners() external view returns (address[] memory) {
        return owners;
    }

    function getThreshold() external view returns (uint256) {
        return numConfirmationsReqeust;
    }

    function isTransitionConfirmed(
        uint256 txIndex,
        address owner
    ) external view returns (bool) {
        return isConfirmed[txIndex][owner];
    }

    function getConfirmationCount(
        uint256 txIndex
    ) public view txExists(txIndex) returns (uint256) {
        return transactions[txIndex].numConfirmations;
    }

    function canExcute(
        uint256 txIndex
    ) public view txExists(txIndex) returns (bool) {
        Transaction storage transaction = transactions[txIndex];
        return
            !transaction.executed &&
            transaction.numConfirmations >= numConfirmationsReqeust;
    }

    receive() external payable {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    fallback() external payable {
        if (msg.value > 0) {
            emit Deposit(msg.sender, msg.value);
        }
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}
