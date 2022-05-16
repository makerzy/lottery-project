// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;
import "./ERC20.sol";

contract MyToken is ERC20 {
    constructor() ERC20("My Token", "MTK") {
        _mint(msg.sender, 10000 ether);
    }
}
