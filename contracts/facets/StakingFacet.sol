// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.27;
import "../libraries/LibAppStorage.sol";
import "../JayToken.sol";
import "../interfaces/IERC20.sol";
// import "../../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
contract StakingFacet {
     LibAppStorage.Layout internal jay;

     constructor (address token) {
        jay.myToken = token;
        jay.nftForPool = 1;
     }
     function stake(uint _amount, uint8 _poolId) external {
        require(_poolId <= 2, "invalid pool");
        
        require(JayToken(jay.myToken).balanceOf(msg.sender) > _amount, "insufficient tokens");

        JayToken(jay.myToken).transferFrom(msg.sender, address(this), _amount);

        uint256[3] memory duration;
        duration[0] = block.timestamp + (7 * 24 * 60 * 60); // 1 week
        duration[1] =  block.timestamp + (14 * 24 * 60 * 60); // 2 weeks
        duration[2] =    block.timestamp + (21 * 24 * 60 * 60); // 3 weeks

        uint8 numberOfNft = jay.nftForPool;
        uint256 _finishesAt = duration[_poolId];
        LibAppStorage.Pools _poolType = LibAppStorage.Pools(_poolId);

        jay.stakes[msg.sender] = LibAppStorage.Stake({
            amountStaked: _amount,
            stakedAt: block.timestamp,
            finishesAt: _finishesAt,
            nftReward: numberOfNft,
            claimed: false,
            poolType: _poolType
        });


        emit LibAppStorage.Staked(msg.sender, _amount, _poolId);
    }

    function getBalance(address _user) external view returns (uint) {
        return JayToken(jay.myToken).getBalanceOf(_user);
    }
}
