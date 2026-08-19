// SPDX-License-Identifier: AGPL-3.0-or-later
// Copyright (C) 2021 Dai Foundation
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
pragma solidity >=0.8.0;

import "../DssTest.sol";

contract SomeContract {
    modifier myModifier { if (1 != 0) revert("SomeContract/bad-state"); _; }    // Conditional gets rid of code unreachable warning
    function withModifier(uint256 arg) external myModifier {}
    function withoutModifier(uint256 arg) external {}
}

contract ModifierUnitTest is DssTest {

    /**
     * @dev Runs `checkModifier` through an external call, so a failure inside it can be detected
     *      here instead of failing this test.
     *      `checkModifier` reports a failure through forge-std's `fail()`, which flags the test
     *      rather than reverting, so the flag is what has to be read and then cleared. `fail()`
     *      records it in two places: in this contract, where reverting the external call rolls it
     *      back, and in the cheatcode address, which survives the revert and is reset below.
     */
    function checkModifierPasses(address _base, bytes4 _fsig) internal returns (bool ok) {
        bytes4[1] memory fsigs = [_fsig];
        (ok,) = address(this).call(abi.encodeCall(this.checkModifierExternal, (_base, "SomeContract/bad-state", fsigs)));
        vm.store(address(vm), bytes32("failed"), bytes32(uint256(0)));
    }

    /// @dev Only meant to be called by `checkModifierPasses`.
    function checkModifierExternal(address _base, string memory _revertMsg, bytes4[1] memory _fsigs) external {
        checkModifier(_base, _revertMsg, _fsigs);
        require(!failed(), "ModifierUnitTest/check-modifier-failed");
    }

    function test_modifier() public {
        checkModifier(address(new SomeContract()), "SomeContract/bad-state", [SomeContract.withModifier.selector]);
    }
    function test_modifier_detects_not_present() public {
        assertFalse(
            checkModifierPasses(address(new SomeContract()), SomeContract.withoutModifier.selector),
            "missing modifier accepted"
        );
    }

}
