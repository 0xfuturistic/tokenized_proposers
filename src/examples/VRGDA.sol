// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ProposerManager} from "../ProposerManager.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {toDaysWadUnsafe} from "solmate/utils/SignedWadMath.sol";
import {LinearVRGDA} from "VRGDAs/LinearVRGDA.sol";

contract VRGDA is ProposerManager, LinearVRGDA {
    uint256 public immutable startTime = block.timestamp; // When VRGDA sales begun.

    constructor(address l2OutputOracle, address erc6551Registry, address proposerAccountImpl)
        ProposerManager(l2OutputOracle, erc6551Registry, proposerAccountImpl)
        LinearVRGDA(
            69.42e18, // Target price.
            0.31e18, // Price decay percent.
            2e18 // Per time unit.
        )
    {}

    function acquireProposer() public payable override returns (uint256 tokenId) {
        unchecked {
            // Note: By using toDaysWadUnsafe(block.timestamp - startTime) we are establishing that 1 "unit of time" is 1 day.
            uint256 price = getVRGDAPrice(toDaysWadUnsafe(block.timestamp - startTime), totalMinted + 1);

            require(msg.value >= price, "UNDERPAID"); // Don't allow underpaying.

            super.acquireProposer();

            // Note: We do this at the end to avoid creating a reentrancy vector.
            // Refund the user any ETH they spent over the current price of the NFT.
            // Unchecked is safe here because we validate msg.value >= price above.
            SafeTransferLib.safeTransferETH(msg.sender, msg.value - price);
        }
    }
}
