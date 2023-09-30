// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ProposerManager} from "../ProposerManager.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {toDaysWadUnsafe} from "solmate/utils/SignedWadMath.sol";
import {LinearVRGDA} from "VRGDAs/LinearVRGDA.sol";

contract VRGDA is ProposerManager, LinearVRGDA {
    uint256 public totalSold; // The total number of tokens sold so far.

    uint256 public immutable startTime = block.timestamp; // When VRGDA sales begun.

    constructor(address l2OutputOracleAddr)
        ProposerManager(l2OutputOracleAddr)
        LinearVRGDA(
            69.42e18, // Target price.
            0.31e18, // Price decay percent.
            2e18 // Per time unit.
        )
    {}

    function acquireProposer() external override returns (uint256 id) {
        _safeMint(msg.sender, id);
    }
}
