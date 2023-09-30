// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

struct OutputProposal {
    bytes32 outputRoot;
    uint128 timestamp;
    uint128 l2BlockNumber;
}

interface IL2OutputOracle {
    /// @notice Getter for the output proposal submission interval.
    function submissionInterval() external view returns (uint256);

    /// @notice Getter for the L2 block time.
    function l2BlockTime() external view returns (uint256);
    /// @notice Getter for the finalization period.

    function finalizationPeriodSeconds() external view returns (uint256);

    /// @notice Getter for the challenger address. This will be removed
    ///         in the future, use `challenger` instead.
    /// @custom:legacy
    function CHALLENGER() external view returns (address);

    /// @notice Getter for the proposer address. This will be removed in the
    ///         future, use `proposer` instead.
    /// @custom:legacy
    function PROPOSER() external view returns (address);

    /// @notice Deletes all output proposals after and including the proposal that corresponds to
    ///         the given output index. Only the challenger address can delete outputs.
    /// @param _l2OutputIndex Index of the first L2 output to be deleted.
    ///                       All outputs after this output will also be deleted.
    // solhint-disable-next-line ordering
    function deleteL2Outputs(uint256 _l2OutputIndex) external;

    /// @notice Accepts an outputRoot and the timestamp of the corresponding L2 block.
    ///         The timestamp must be equal to the current value returned by `nextTimestamp()` in
    ///         order to be accepted. This function may only be called by the Proposer.
    /// @param _outputRoot    The L2 output of the checkpoint block.
    /// @param _l2BlockNumber The L2 block number that resulted in _outputRoot.
    /// @param _l1BlockHash   A block hash which must be included in the current chain.
    /// @param _l1BlockNumber The block number with the specified block hash.
    function proposeL2Output(bytes32 _outputRoot, uint256 _l2BlockNumber, bytes32 _l1BlockHash, uint256 _l1BlockNumber)
        external
        payable;

    /// @notice Returns an output by index. Needed to return a struct instead of a tuple.
    /// @param _l2OutputIndex Index of the output to return.
    /// @return The output at the given index.
    function getL2Output(uint256 _l2OutputIndex) external view returns (OutputProposal memory);

    /// @notice Returns the L2 output proposal that checkpoints a given L2 block number.
    ///         Uses a binary search to find the first output greater than or equal to the given
    ///         block.
    /// @param _l2BlockNumber L2 block number to find a checkpoint for.
    /// @return First checkpoint that commits to the given L2 block number.
    function getL2OutputAfter(uint256 _l2BlockNumber) external view returns (OutputProposal memory);

    /// @notice Returns the number of outputs that have been proposed.
    ///         Will revert if no outputs have been proposed yet.
    /// @return The number of outputs that have been proposed.
    function latestOutputIndex() external view returns (uint256);
}
