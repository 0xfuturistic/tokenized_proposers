// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {IL2OutputOracle} from "./IL2OutputOracle.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC6551Registry} from "erc6551/ERC6551Registry.sol";

contract ProposerManager is ERC721 {
    address public immutable L2_OUTPUT_ORACLE;

    address public immutable ERC6551_REGISTRY;

    address public immutable PROPOSER_ACCOUNT_IMPL;

    uint256 public totalMinted;

    event ProposerAcquired(address indexed buyer, uint256 indexed tokenId, address indexed account);

    constructor(address l2OutputOracle, address erc6551Registry, address proposerAccountImpl)
        ERC721("MyToken", "MTK")
    {
        L2_OUTPUT_ORACLE = l2OutputOracle;
        ERC6551_REGISTRY = erc6551Registry;
        PROPOSER_ACCOUNT_IMPL = proposerAccountImpl;
    }

    function proposeL2Output(bytes32 _outputRoot, uint256 _l2BlockNumber, bytes32 _l1BlockHash, uint256 _l1BlockNumber)
        external
        payable
    {
        require(msg.sender == getNextProposer(), "NOT_PROPOSER");

        IL2OutputOracle(L2_OUTPUT_ORACLE).proposeL2Output{value: msg.value}(
            _outputRoot, _l2BlockNumber, _l1BlockHash, _l1BlockNumber
        );
    }

    /// @notice this should return the account of the next proposer
    function getNextProposer() public view returns (address) {
        return ERC6551Registry(ERC6551_REGISTRY).account(
            PROPOSER_ACCOUNT_IMPL,
            block.chainid,
            address(this),
            IL2OutputOracle(L2_OUTPUT_ORACLE).latestOutputIndex() + 1,
            0
        );
    }

    function acquireProposer() public payable virtual returns (uint256, address) {
        totalMinted++;
        _mint(msg.sender, totalMinted);

        address account = ERC6551Registry(ERC6551_REGISTRY).createAccount(
            PROPOSER_ACCOUNT_IMPL, block.chainid, address(this), totalMinted, 0, ""
        );

        emit ProposerAcquired(msg.sender, totalMinted, account);

        return (totalMinted, account);
    }
}
