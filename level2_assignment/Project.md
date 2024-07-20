去中心化众筹平台

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Project {
    // 定义项目的三种状态：正在进行中、成功、失败
    enum ProjectState { Ongoing, Successful, Failed }

    // 定义捐赠结构体，包含捐赠者地址和捐赠金额
    struct Donation {
        address donor;
        uint256 amount;
    }

    // 创建者地址
    address public creator;
    // 项目描述
    string public description;
    // 目标金额
    uint256 public goalAmount;
    // 截止日期的时间戳
    uint256 public deadline;
    // 当前募集的总金额
    uint256 public currentAmount;
    // 项目当前状态
    ProjectState public state;
    // 所有捐赠记录列表
    Donation[] public donations;

    // 事件：当收到捐赠时触发
    event DonationReceived(address indexed donor, uint256 amount);
    // 事件：当项目状态改变时触发
    event ProjectStateChanged(ProjectState newState);
    // 事件：当创建者提取资金时触发
    event FundsWithdrawn(address indexed creator, uint256 amount);
    // 事件：当捐赠者收到退款时触发
    event FundsRefunded(address indexed donor, uint256 amount);

    // 只允许创建者调用的修饰符
    modifier onlyCreator() {
        require(msg.sender == creator, "Not the project creator");
        _;
    }

    // 只允许在截止日期后调用的修饰符
    modifier onlyAfterDeadline() {
        require(block.timestamp >= deadline, "Project is still ongoing");
        _;
    }

    // 初始化项目，设置创建者、描述、目标金额和持续时间
    function initialize(address _creator, string memory _description, uint256 _goalAmount, uint256 _duration) public {
        creator = _creator;
        description = _description;
        goalAmount = _goalAmount;
        deadline = block.timestamp + _duration;
        state = ProjectState.Ongoing;
    }

    // 允许外部账户向项目捐赠ETH
    function donate() external payable {
        require(state == ProjectState.Ongoing, "Project is not ongoing");
        require(block.timestamp < deadline, "Project deadline has passed");

        // 添加捐赠记录
        donations.push(Donation({
            donor: msg.sender,
            amount: msg.value
        }));

        // 增加当前募集金额
        currentAmount += msg.value;

        // 触发捐赠事件
        emit DonationReceived(msg.sender, msg.value);
    }

    // 创建者在项目成功后可以提取所有资金
    function withdrawFunds() external onlyCreator onlyAfterDeadline {
        require(state == ProjectState.Successful, "Project is not successful");

        // 获取合约余额
        uint256 amount = address(this).balance;
        // 转账给创建者
        payable(creator).transfer(amount);

        // 触发资金提取事件
        emit FundsWithdrawn(creator, amount);
    }

    // 在项目失败后，允许捐赠者请求退款
    function refund() external onlyAfterDeadline {
        require(state == ProjectState.Failed, "Project is not failed");

        // 计算捐赠者应得的退款总额
        uint256 totalRefund = 0;
        for (uint256 i = 0; i < donations.length; i++) {
            if (donations[i].donor == msg.sender) {
                totalRefund += donations[i].amount;
                donations[i].amount = 0; // 标记为已退款
            }
        }

        require(totalRefund > 0, "No funds to refund");

        // 退款给捐赠者
        payable(msg.sender).transfer(totalRefund);

        // 触发退款事件
        emit FundsRefunded(msg.sender, totalRefund);
    }

    // 更新项目状态，根据募集金额判断项目是否成功或失败
    function updateProjectState() external onlyAfterDeadline {
        require(state == ProjectState.Ongoing, "Project is already finalized");

        if (currentAmount >= goalAmount) {
            state = ProjectState.Successful;
        } else {
            state = ProjectState.Failed;
        }

        // 触发项目状态改变事件
        emit ProjectStateChanged(state);
    }
}
```

