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

contract ValidFileContract {
    mapping (address => uint256) public wards;
    uint256 public someData;
    address public vow;
    string public someStr;
    event Rely(address indexed usr);
    event Deny(address indexed usr);
    event File(bytes32 indexed what, uint256 data);
    event File(bytes32 indexed what, address data);
    event File(bytes32 indexed what, string data);
    constructor() { wards[msg.sender] = 1; emit Rely(msg.sender); }
    modifier auth { require(wards[msg.sender] == 1, "FileContract/not-authorized"); _; }
    function rely(address usr) external auth { wards[usr] = 1; emit Rely(usr); }
    function deny(address usr) external auth { wards[usr] = 0; emit Deny(usr); }
    function file(bytes32 what, uint256 data) external auth {
        if (what == "someData") {
            someData = data;
        } else {
            revert("FileContract/file-unrecognized-param");
        }
        emit File(what, data);
    }
    function file(bytes32 what, address data) external auth {
        if (what == "vow") {
            vow = data;
        } else {
            revert("FileContract/file-unrecognized-param");
        }
        emit File(what, data);
    }
    function file(bytes32 what, string calldata data) external auth {
        if (what == "someStr") {
            someStr = data;
        } else {
            revert("FileContract/file-unrecognized-param");
        }
        emit File(what, data);
    }
}
contract InvalidFileContractRevertName {
    mapping (address => uint256) public wards;
    uint256 public someData;
    address public vow;
    string public someStr;
    event Rely(address indexed usr);
    event Deny(address indexed usr);
    event File(bytes32 indexed what, uint256 data);
    event File(bytes32 indexed what, address data);
    event File(bytes32 indexed what, string data);
    constructor() { wards[msg.sender] = 1; emit Rely(msg.sender); }
    modifier auth { require(wards[msg.sender] == 1, "FileContract/not-authorized"); _; }
    function rely(address usr) external auth { wards[usr] = 1; emit Rely(usr); }
    function deny(address usr) external auth { wards[usr] = 0; emit Deny(usr); }
    function file(bytes32 what, uint256 data) external auth {
        if (what == "someData") {
            someData = data;
        } else {
            revert("BadName/file-unrecognized-param");
        }
        emit File(what, data);
    }
    function file(bytes32 what, address data) external auth {
        if (what == "vow") {
            vow = data;
        } else {
            revert("BadName/file-unrecognized-param");
        }
        emit File(what, data);
    }
    function file(bytes32 what, string calldata data) external auth {
        if (what == "someStr") {
            someStr = data;
        } else {
            revert("BadName/file-unrecognized-param");
        }
        emit File(what, data);
    }
}
contract InvalidFileContractMissingUpdate {
    mapping (address => uint256) public wards;
    uint256 public someData;
    address public vow;
    string public someStr;
    event Rely(address indexed usr);
    event Deny(address indexed usr);
    event File(bytes32 indexed what, uint256 data);
    event File(bytes32 indexed what, address data);
    event File(bytes32 indexed what, string data);
    constructor() { wards[msg.sender] = 1; emit Rely(msg.sender); }
    modifier auth { require(wards[msg.sender] == 1, "FileContract/not-authorized"); _; }
    function rely(address usr) external auth { wards[usr] = 1; emit Rely(usr); }
    function deny(address usr) external auth { wards[usr] = 0; emit Deny(usr); }
    function file(bytes32 what, uint256 data) external auth {
        if (what == "someData") {
        } else {
            revert("FileContract/file-unrecognized-param");
        }
        emit File(what, data);
    }
    function file(bytes32 what, address data) external auth {
        if (what == "vow") {
        } else {
            revert("FileContract/file-unrecognized-param");
        }
        emit File(what, data);
    }
    function file(bytes32 what, string calldata data) external auth {
        if (what == "someStr") {
        } else {
            revert("FileContract/file-unrecognized-param");
        }
        emit File(what, data);
    }
}
contract InvalidFileContractMissingAuth {
    mapping (address => uint256) public wards;
    uint256 public someData;
    address public vow;
    string public someStr;
    event Rely(address indexed usr);
    event Deny(address indexed usr);
    event File(bytes32 indexed what, uint256 data);
    event File(bytes32 indexed what, address data);
    event File(bytes32 indexed what, string data);
    constructor() { wards[msg.sender] = 1; emit Rely(msg.sender); }
    modifier auth { require(wards[msg.sender] == 1, "FileContract/not-authorized"); _; }
    function rely(address usr) external auth { wards[usr] = 1; emit Rely(usr); }
    function deny(address usr) external auth { wards[usr] = 0; emit Deny(usr); }
    function file(bytes32 what, uint256 data) external {
        if (what == "someData") {
            someData = data;
        } else {
            revert("FileContract/file-unrecognized-param");
        }
        emit File(what, data);
    }
    function file(bytes32 what, address data) external {
        if (what == "vow") {
            vow = data;
        } else {
            revert("FileContract/file-unrecognized-param");
        }
        emit File(what, data);
    }
    function file(bytes32 what, string calldata data) external {
        if (what == "someStr") {
            someStr = data;
        } else {
            revert("FileContract/file-unrecognized-param");
        }
        emit File(what, data);
    }
}

contract FileUnitTest is DssTest {

    /// @dev Runs a `checkFile*` helper through an external call, so a failure inside it can be
    ///      detected here instead of failing this test. The helpers call `vm.expectRevert`
    ///      themselves, so the test cannot wrap them in another one.
    function checkFilePasses(bytes memory _call) internal returns (bool ok) {
        (ok,) = address(this).call(_call);
    }

    /// @dev The three functions below are only meant to be called by `checkFilePasses`.
    function checkFileUintExternal(address _base, string memory _contractName, string[1] memory _values) external {
        checkFileUint(_base, _contractName, _values);
    }
    function checkFileAddressExternal(address _base, string memory _contractName, string[1] memory _values) external {
        checkFileAddress(_base, _contractName, _values);
    }
    function checkFileStringExternal(address _base, string memory _contractName, string[1] memory _values) external {
        checkFileString(_base, _contractName, _values);
    }

    function checkFileUintPasses(address _base) internal returns (bool) {
        return checkFilePasses(abi.encodeCall(this.checkFileUintExternal, (_base, "FileContract", ["someData"])));
    }
    function checkFileAddressPasses(address _base) internal returns (bool) {
        return checkFilePasses(abi.encodeCall(this.checkFileAddressExternal, (_base, "FileContract", ["vow"])));
    }
    function checkFileStringPasses(address _base) internal returns (bool) {
        return checkFilePasses(abi.encodeCall(this.checkFileStringExternal, (_base, "FileContract", ["someStr"])));
    }

    function test_file_uint_valid() public {
        checkFileUint(address(new ValidFileContract()), "FileContract", ["someData"]);
    }
    function test_file_uint_detects_revert_name() public {
        assertFalse(checkFileUintPasses(address(new InvalidFileContractRevertName())), "unexpected revert name accepted");
    }
    function test_file_uint_detects_missing_update() public {
        assertFalse(checkFileUintPasses(address(new InvalidFileContractMissingUpdate())), "missing update accepted");
    }
    function test_file_uint_detects_missing_auth() public {
        assertFalse(checkFileUintPasses(address(new InvalidFileContractMissingAuth())), "missing auth accepted");
    }

    function test_file_address_valid() public {
        checkFileAddress(address(new ValidFileContract()), "FileContract", ["vow"]);
    }
    function test_file_address_detects_revert_name() public {
        assertFalse(checkFileAddressPasses(address(new InvalidFileContractRevertName())), "unexpected revert name accepted");
    }
    function test_file_address_detects_missing_update() public {
        assertFalse(checkFileAddressPasses(address(new InvalidFileContractMissingUpdate())), "missing update accepted");
    }
    function test_file_address_detects_missing_auth() public {
        assertFalse(checkFileAddressPasses(address(new InvalidFileContractMissingAuth())), "missing auth accepted");
    }

    function test_file_string_valid() public {
        checkFileString(address(new ValidFileContract()), "FileContract", ["someStr"]);
    }
    function test_file_string_detects_revert_name() public {
        assertFalse(checkFileStringPasses(address(new InvalidFileContractRevertName())), "unexpected revert name accepted");
    }
    function test_file_string_detects_missing_update() public {
        assertFalse(checkFileStringPasses(address(new InvalidFileContractMissingUpdate())), "missing update accepted");
    }
    function test_file_string_detects_missing_auth() public {
        assertFalse(checkFileStringPasses(address(new InvalidFileContractMissingAuth())), "missing auth accepted");
    }
}
