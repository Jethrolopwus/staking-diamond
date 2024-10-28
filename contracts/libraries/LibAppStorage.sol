// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.27;

library LibAppStorage {

    enum Pools { oneWeekPool, twoWeeksPool, threeWeeksPool }

    error TimeHasNotFinished();

    // Events to track staking actions
    event Staked(address indexed user, uint256 amount, uint8 poolId);
    event RewardClaimed(address indexed user, uint8 nft, bool convertTokenToNft);

    struct Stake {
        uint256 amountStaked;
        uint256 stakedAt;
        uint256 finishesAt;
        uint8 nftReward;
        Pools poolType;
        bool claimed;
    }
    
    struct Layout {
        address owner;
        address myToken;
        uint8 numberOfTokensPerReward;
        uint8 nftForPool;
        mapping(address => Stake) stakes;
    }
}



