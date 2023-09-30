// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IL2OutputOracle} from "./IL2OutputOracle.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

abstract contract ProposerManager is ERC721 {
    IL2OutputOracle public immutable l2OutputOracle; // The L2 output oracle.

    constructor(address l2OutputOracleAddr) ERC721("MyToken", "MTK") {
        l2OutputOracle = IL2OutputOracle(l2OutputOracleAddr);
    }

    function proposeL2Output(bytes32 _outputRoot, uint256 _l2BlockNumber, bytes32 _l1BlockHash, uint256 _l1BlockNumber)
        external
        payable
    {
        l2OutputOracle.proposeL2Output{value: msg.value}(_outputRoot, _l2BlockNumber, _l1BlockHash, _l1BlockNumber);
    }

    function acquireProposer() external virtual returns (uint256 id);

    function tokenURI(uint256) public pure override returns (string memory) {
        return "https://example.com";
    }
}
