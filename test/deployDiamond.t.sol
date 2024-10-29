// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;
import "../contracts/interfaces/IDiamondCut.sol";
import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../contracts/JayToken.sol";
import "../contracts/facets/StakingFacet.sol";
import "../contracts/Diamond.sol";

contract DiamondDeployer is Test, IDiamondCut  {
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    JayToken jayToken;
    StakingFacet stakingFacet;

    address owner;
    address usera;
    address userb;

    function setUp () public {
        owner = address(this);
        usera = address(0x1);
        userb = address(0x2);
        dCutFacet = new DiamondCutFacet();
        dLoupe = new DiamondLoupeFacet();
        diamond = new Diamond(address(this), address(dCutFacet));
        ownerF = new OwnershipFacet();
        jayToken = new JayToken("JayToken");
        stakingFacet = new StakingFacet(address(jayToken));
    }

    function testDeployDiamond() public {
         dCutFacet = new DiamondCutFacet();
        dLoupe = new DiamondLoupeFacet();
        diamond = new Diamond(address(this), address(dCutFacet));
        ownerF = new OwnershipFacet();
        jayToken = new JayToken("JayToken");
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
    }


    function generateSelectors(string memory _facetName) internal returns (bytes4[] memory selectors) {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/genSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res,(bytes4[])); 
    } 

    function testMint() public {
        vm.prank(address(this));
        jayToken.mint(usera, 1000);
        assert(jayToken.getBalanceOf(usera) == 1000);
    }

    function testTransferFrom() public {
        jayToken.mint(usera, 1e18);
        vm.prank(usera);
        jayToken.approve(owner, 1e18);

        vm.prank(owner);
        jayToken.transferFrom(usera,userb, 1e18);


        assert(jayToken.getBalanceOf(userb) == 1e18);
        assert(jayToken.getBalanceOf(usera) == 0);
    }
function testStakePool()  public {
    vm.prank(usera);
    vm.expectRevert("invalid pool");
    stakingFacet.stake(10, 4);
}
function testStake() public {
    vm.prank(usera);
    uint userBal = stakingFacet.getBalance(usera);
    assert(userBal == 0);
}

function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
    
}



