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

contract ValidAuthContract {
    event Rely(address indexed usr);
    event Deny(address indexed usr);
    mapping (address => uint256) public wards;
    modifier auth { require(wards[msg.sender] == 1, "AuthContract/not-authorized"); _; }
    function rely(address usr) external auth { wards[usr] = 1; emit Rely(usr); }
    function deny(address usr) external auth { wards[usr] = 0; emit Deny(usr); }
    constructor() { wards[msg.sender] = 1; emit Rely(msg.sender); }
}
contract InvalidAuthContractRevertName {
    event Rely(address indexed usr);
    event Deny(address indexed usr);
    mapping (address => uint256) public wards;
    modifier auth { require(wards[msg.sender] == 1, "BadName/not-authorized"); _; }
    function rely(address usr) external auth { wards[usr] = 1; emit Rely(usr); }
    function deny(address usr) external auth { wards[usr] = 0; emit Deny(usr); }
    constructor() { wards[msg.sender] = 1; emit Rely(msg.sender); }
}
contract InvalidAuthContractRely1 {
    event Rely(address indexed usr);
    event Deny(address indexed usr);
    mapping (address => uint256) public wards;
    modifier auth { require(wards[msg.sender] == 1, "AuthContract/not-authorized"); _; }
    function rely(address usr) external auth { wards[usr] = 0; emit Rely(usr); }
    function deny(address usr) external auth { wards[usr] = 0; emit Deny(usr); }
    constructor() { wards[msg.sender] = 1; emit Rely(msg.sender); }
}
contract InvalidAuthContractRely2 {
    event Rely(address indexed usr);
    event Deny(address indexed usr);
    mapping (address => uint256) public wards;
    modifier auth { require(wards[msg.sender] == 1, "AuthContract/not-authorized"); _; }
    function rely(address usr) external auth { wards[usr] = 1; emit Rely(msg.sender); }
    function deny(address usr) external auth { wards[usr] = 0; emit Deny(usr); }
    constructor() { wards[msg.sender] = 1; emit Rely(msg.sender); }
}
contract InvalidAuthContractRely3 {
    event Rely(address indexed usr);
    event Deny(address indexed usr);
    mapping (address => uint256) public wards;
    modifier auth { require(wards[msg.sender] == 1, "AuthContract/not-authorized"); _; }
    function rely(address usr) external auth { wards[usr] = 1; emit Deny(usr); }
    function deny(address usr) external auth { wards[usr] = 0; emit Deny(usr); }
    constructor() { wards[msg.sender] = 1; emit Rely(msg.sender); }
}
contract InvalidAuthContractDeny1 {
    event Rely(address indexed usr);
    event Deny(address indexed usr);
    mapping (address => uint256) public wards;
    modifier auth { require(wards[msg.sender] == 1, "AuthContract/not-authorized"); _; }
    function rely(address usr) external auth { wards[usr] = 1; emit Rely(usr); }
    function deny(address usr) external auth { wards[usr] = 1; emit Deny(usr); }
    constructor() { wards[msg.sender] = 1; emit Rely(msg.sender); }
}
contract InvalidAuthContractDeny2 {
    event Rely(address indexed usr);
    event Deny(address indexed usr);
    mapping (address => uint256) public wards;
    modifier auth { require(wards[msg.sender] == 1, "AuthContract/not-authorized"); _; }
    function rely(address usr) external auth { wards[usr] = 1; emit Rely(usr); }
    function deny(address usr) external auth { wards[usr] = 0; emit Deny(msg.sender); }
    constructor() { wards[msg.sender] = 1; emit Rely(msg.sender); }
}
contract InvalidAuthContractDeny3 {
    event Rely(address indexed usr);
    event Deny(address indexed usr);
    mapping (address => uint256) public wards;
    modifier auth { require(wards[msg.sender] == 1, "AuthContract/not-authorized"); _; }
    function rely(address usr) external auth { wards[usr] = 1; emit Rely(usr); }
    function deny(address usr) external auth { wards[usr] = 0; emit Rely(usr); }
    constructor() { wards[msg.sender] = 1; emit Rely(msg.sender); }
}

contract AuthUnitTest is DssTest {

    /**
     * @dev Runs `checkAuth` through an external call, so a failure inside it can be detected
     *      here instead of failing this test.
     *      `checkAuth` verifies events with `vm.expectEmit`. When it aborts early, an expectation
     *      it queued may still be unmatched, and unmatched expectations are reported when the test
     *      ends, no matter which call registered them. The events `checkAuth` expects are therefore
     *      re-emitted below to consume whatever it left behind.
     *      `checkAuth` calls `vm.expectRevert` itself, so the test cannot wrap it in another one.
     */
    function checkAuthPasses(address _base) internal returns (bool ok) {
        (ok,) = address(this).call(abi.encodeCall(this.checkAuthExternal, (_base, "AuthContract")));
        emit Rely(TEST_ADDRESS);
        emit Deny(TEST_ADDRESS);
    }

    /// @dev Only meant to be called by `checkAuthPasses`.
    function checkAuthExternal(address _base, string memory _contractName) external {
        checkAuth(_base, _contractName);
    }

    function test_auth_valid() public {
        checkAuth(address(new ValidAuthContract()), "AuthContract");
    }
    function test_auth_detects_revert_name() public {
        assertFalse(checkAuthPasses(address(new InvalidAuthContractRevertName())), "unexpected revert name accepted");
    }
    function test_auth_detects_bad_rely1() public {
        assertFalse(checkAuthPasses(address(new InvalidAuthContractRely1())), "rely not granting auth accepted");
    }
    function test_auth_detects_bad_rely2() public {
        assertFalse(checkAuthPasses(address(new InvalidAuthContractRely2())), "rely emitting the wrong usr accepted");
    }
    function test_auth_detects_bad_rely3() public {
        assertFalse(checkAuthPasses(address(new InvalidAuthContractRely3())), "rely emitting Deny accepted");
    }
    function test_auth_detects_bad_deny1() public {
        assertFalse(checkAuthPasses(address(new InvalidAuthContractDeny1())), "deny not revoking auth accepted");
    }
    function test_auth_detects_bad_deny2() public {
        assertFalse(checkAuthPasses(address(new InvalidAuthContractDeny2())), "deny emitting the wrong usr accepted");
    }
    function test_auth_detects_bad_deny3() public {
        assertFalse(checkAuthPasses(address(new InvalidAuthContractDeny3())), "deny emitting Rely accepted");
    }

}
