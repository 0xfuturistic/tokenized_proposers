// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {VRGDA} from "../src/examples/VRGDA.sol";

contract VRGDATest is Test {
    VRGDA public vrgda;

    function setUp() public {
        vrgda = new VRGDA(address(0));
    }
}
