//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./access/Ownable.sol";
import "./library/SafeERC20.sol";
import "./interfaces/IERC20.sol";

contract Lottery is Ownable {
    /**
     * This contract is authored by Sam (botassammzy@gmail.com)
     * GitHub         https://github.com/makerzy
     * Twitter        https://twitter.com/makerz_dev
     * Telegram       https://t.me/@mayboyo2
     */

    using SafeERC20 for IERC20;
    IERC20 public immutable token;

    string public constant name = "Simple Lottery With On-chain Randomness";

    // loteryId => winningNumber => addresses of users
    mapping(uint256 => mapping(uint256 => address[])) public potentialWinners;
    mapping(uint256 => bytes32) private initBytes;
    mapping(address => bool) public entered;
    mapping(uint256 => bool) public initialized;
    mapping(uint256 => bool) public ended;
    mapping(uint256 => uint256) public lotteryPool;
    mapping(uint256 => address) public winner;

    event Entered(uint256 lotteryId, address user);
    event Initialized(uint256 lotteryId);
    event WinnerPicked(
        uint256 lotteryId,
        address winner,
        uint256 lotteryValue,
        uint256 pool
    );

    uint256 public entryFees;

    constructor(IERC20 _token) {
        token = _token;
    }

    function initLottery(uint256 lotteryId) external {
        onlyOwner();
        require(!initialized[lotteryId], "initialized");
        initialized[lotteryId] = true;
        emit Initialized(lotteryId);
    }

    function enterLottery(uint256 lotteryId, uint256[] calldata winningNums)
        external
    {
        require(!entered[_msgSender()] && !ended[lotteryId], "entered");
        entered[_msgSender()] = true;
        uint256 len = winningNums.length;
        uint256 reqValue = len * entryFees;
        token.safeTransferFrom(_msgSender(), address(this), reqValue);
        lotteryPool[lotteryId] += reqValue;
        for (uint256 i = 0; i < len; i++) {
            _enterLotttery(_msgSender(), lotteryId, winningNums[i]);
        }
        initBytes[lotteryId] = hash(
            abi.encode(
                initBytes[lotteryId],
                _msgSender(),
                lotteryId,
                winningNums
            ),
            lotteryId
        );
        emit Entered(lotteryId, _msgSender());
    }

    function _enterLotttery(
        address user,
        uint256 _lotteryId,
        uint256 _winningNum
    ) private {
        potentialWinners[_lotteryId][_winningNum].push(user);
    }

    function hash(bytes memory bytesVal, uint256 id)
        private
        view
        returns (bytes32)
    {
        return keccak256(abi.encode(initBytes[id], block.difficulty, bytesVal));
    }

    function pickWinner(uint256 lotteryId) external {
        onlyOwner();
        require(!ended[lotteryId], "replay");
        ended[lotteryId] = true;
        address _winner;
        uint256 lotteryValue = uint256(random(initBytes[lotteryId]));
        address[] memory winners = potentialWinners[lotteryId][lotteryValue];
        if(winners.length ==0) return;
        lotteryValue = lotteryValue % winners.length;
        _winner = winners[lotteryValue];
        
        winner[lotteryId] = _winner;
        uint256 pool = lotteryPool[lotteryId];
        token.safeTransfer(_winner, pool);
        emit WinnerPicked(lotteryId, _winner, lotteryValue, pool);
    }

    // Withdraw locked token to owner account
    function withdraw()external{
        onlyOwner();
        token.safeTransfer(owner(), token.balanceOf(address(this)));
    }

    function random(bytes32 salt) private view returns (uint16) {
        return
            uint16(
                uint256(
                    keccak256(
                        abi.encode(block.timestamp, block.difficulty, salt)
                    )
                ) % uint96(uint256(keccak256(bytes(name))))
            );
    }
}
