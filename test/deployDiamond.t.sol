// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../contracts/Diamond.sol";
import "../contracts/JayToken.sol";
import "../contracts/facets/StakingFacet.sol";

contract DiamondDeployer is Test, IDiamondCut {
       
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    JayToken jayToken;
    StakingFacet stakingFacet;

    address owner;
    address a;
    address b;

    function setUp () public {
        owner = address(this);
        a = address(0x1);
        b = address(0x2);
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(this), address(dCutFacet));
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        jayToken = new JayToken("JayToken");
        stakingFacet = new StakingFacet(address(jayToken));
    }
    function testDeployDiamond() public {

    dCutFacet = new DiamondCutFacet();
    diamond = new Diamond(address(this), address(dCutFacet));
    dLoupe = new DiamondLoupeFacet();
    ownerF = new OwnershipFacet();
    stakingFacet = new StakingFacet(address(jayToken));

    FacetCut[] memory cut = new FacetCut[](3);
    cut[0] = FacetCut({
        facetAddress: address(dLoupe),
        action: FacetCutAction.Add,
        functionSelectors: generateSelectors("DiamondLoupeFacet")
    });
    cut[1] = FacetCut({
        facetAddress: address(ownerF),
        action: FacetCutAction.Add,
        functionSelectors: generateSelectors("OwnershipFacet")
    });
    cut[2] = FacetCut({
        facetAddress: address(stakingFacet),
        action: FacetCutAction.Add,
        functionSelectors: generateSelectors("StakingFacet")
    });

    IDiamondCut(address(diamond)).diamondCut(cut, address(0), "");
    DiamondLoupeFacet(address(diamond)).facetAddresses();
    // assert(facetAddresses.length == 3);
    // console2.log(facetAddresses);
}

  function generateSelectors(
        string memory _facetName
    ) internal returns (bytes4[] memory selectors) {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/genSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
    }

   function testMint() public {
        vm.prank(address(this));
        jayToken.mint(a, 1000);
        assert(jayToken.getBalanceOf(a) == 1000);
   }

   function testTransferFrom() public {
    jayToken.mint(a, 1e18); 
    vm.prank(a);  
    jayToken.approve(owner, 1e18); 

    vm.prank(owner); 
    jayToken.transferFrom(a, b, 1e18);  

    assert(jayToken.getBalanceOf(b) == 1e18);
    assert(jayToken.getBalanceOf(a) == 0);
}



    function testStakePool() public {
        vm.prank(a);
        vm.expectRevert("invalid pool");
        stakingFacet.stake(10, 4);
    }

    function testStake() public {
        vm.prank(a);
        uint userBal = stakingFacet.getBalance(a);
        assert(userBal == 0);
    }
    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}
