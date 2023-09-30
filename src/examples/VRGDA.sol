// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {ProposerManager} from "../ProposerManager.sol";

contract VRGDA is ProposerManager {
    constructor(address l2OutputOracleAddr) ProposerManager(l2OutputOracleAddr) {}

    function acquireProposer() external override returns (uint256 id) {
        _safeMint(msg.sender, id);
    }
}
