// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "../../ERC20/BalancerV2FeeToken.sol";

contract MyBalancerFeeToken is BalancerV2FeeToken {
    constructor()
        BalancerV2FeeToken(
            "My Token",
            "MTKN", // Name and Symbol
            1_000_000_000 ether, // 1 billion supply
            100,
            200,
            50, // Fees: 2% buy 1% sell 0.5% P2P
            msg.sender
        ) // Fee Receiver
    {}
}
