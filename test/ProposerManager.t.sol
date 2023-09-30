// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {ProposerManager} from "../src/ProposerManager.sol";
import {ERC6551Registry} from "erc6551/ERC6551Registry.sol";
import {SimpleERC6551Account} from "erc6551/examples/simple/SimpleERC6551Account.sol";

contract ProposerManagerTest is Test {
    ProposerManager public manager;

    uint256 public outputIndex;

    event L2OutputProposed(bytes32 _outputRoot, uint256 _l2BlockNumber, bytes32 _l1BlockHash, uint256 _l1BlockNumber);

    function setUp() public {
        address l2OutputOracle = address(this);
        address erc6551Registry = address(new ERC6551Registry());
        address proposerAccountImpl = address(new SimpleERC6551Account());
        manager = new ProposerManager(l2OutputOracle, erc6551Registry, proposerAccountImpl);
    }

    function test_acquireProposer() public {
        (uint256 tokenId1,) = manager.acquireProposer();

        (uint256 tokenId2,) = manager.acquireProposer();

        assertEq(tokenId1 + 1, tokenId2);
    }

    function test_getNextProposer() public {
        (, address account1) = manager.acquireProposer();

        assertEq(manager.getNextProposer(), account1);

        manager.acquireProposer();

        assertEq(manager.getNextProposer(), account1);
    }

    function test_proposeL2Output(
        bytes32 _outputRoot,
        uint256 _l2BlockNumber,
        bytes32 _l1BlockHash,
        uint256 _l1BlockNumber
    ) public {
        uint256 outputIndexStart = outputIndex;
        (, address account1) = manager.acquireProposer();
        (, address account2) = manager.acquireProposer();

        assertEq(manager.getNextProposer(), account1);

        vm.expectRevert("NOT_PROPOSER");
        manager.proposeL2Output(_outputRoot, _l2BlockNumber, _l1BlockHash, _l1BlockNumber);

        vm.prank(account1);
        vm.expectCall(address(this), abi.encodeWithSelector(this.proposeL2Output.selector));
        manager.proposeL2Output(_outputRoot, _l2BlockNumber, _l1BlockHash, _l1BlockNumber);

        assertEq(outputIndex, outputIndexStart + 1);
        assertEq(manager.getNextProposer(), account2);
    }

    // Mock L2OutputOracle functions

    function proposeL2Output(bytes32 _outputRoot, uint256 _l2BlockNumber, bytes32 _l1BlockHash, uint256 _l1BlockNumber)
        external
    {
        require(msg.sender == address(manager), "NOT_PROPOSER_MANAGER");
        outputIndex++;
        emit L2OutputProposed(_outputRoot, _l2BlockNumber, _l1BlockHash, _l1BlockNumber);
    }

    function latestOutputIndex() external view returns (uint256) {
        return outputIndex;
    }
}
