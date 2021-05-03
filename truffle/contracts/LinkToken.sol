pragma solidity ^0.6.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


contract LinkToken is ERC20{
    constructor() public ERC20('LinkToken', 'LinkToken') {
        _mint(msg.sender, 2_500_000_000 * 10 ** 18);
    }
}