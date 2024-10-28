// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import {Script} from "../lib/forge-std/src/Script.sol";
// Ensure you have this import

import "forge-std/Script.sol";

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";

import "../contracts/facets/StakingFacet.sol";

import "../contracts/Diamond.sol";

contract MyScript is Script {
    function run() external {
        // my address
        address owner = 0x21726d1CBf49479CA2bc6E7688c6c591C0981F08;
        // switchSigner(owner);
        // uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(
            43db3940e393854a1b3a267e7a9f0dc1a0d7ffabe28d14a12b5010a2949a3e6b
        );
        // vm.startBroadcast(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80);

        DiamondCutFacet dCutFacet = new DiamondCutFacet();
        Diamond diamond = new Diamond(owner, address(dCutFacet));
        DiamondLoupeFacet dLoupe = new DiamondLoupeFacet();
        OwnershipFacet ownerF = new OwnershipFacet();
        // my  staking  facet instance
       StakingFacet stakingFacet = new StakingFacet();
       

        //upgrade diamond with facets

        //build cut struct
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](4);

        cut[0] = (
            IDiamondCut.FacetCut({
                facetAddress: address(dLoupe),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            IDiamondCut.FacetCut({
                facetAddress: address(ownerF),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        cut[2] = (
            IDiamondCut.FacetCut({
                facetAddress: address(stakingFacet),
                action: IDiamondCut.FacetCutAction.Add,
                functionSelectors: generateSelectors("StakingFacet")
            })
        );

        // cut[3] = (
        //     IDiamondCut.FacetCut({
        //         facetAddress: address(enrollmentFacet),
        //         action: IDiamondCut.FacetCutAction.Add,
        //         functionSelectors: generateSelectors("EnrollStudentFacet")
        //     })
        // );

        // cut[4] = (
        //     IDiamondCut.FacetCut({
        //         facetAddress: address(studentFacet),
        //         action: IDiamondCut.FacetCutAction.Add,
        //         functionSelectors: generateSelectors("StudentFacet")
        //     })
        // );

        // cut[5] = (
        //     IDiamondCut.FacetCut({
        //         facetAddress: address(teacherFacet),
        //         action: IDiamondCut.FacetCutAction.Add,
        //         functionSelectors: generateSelectors("TeacherFacet")
        //     })
        // );

        // i_diamond = IDiamond(address(diamond));

        //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        //call a function
        DiamondLoupeFacet(address(diamond)).facetAddresses();

        vm.stopBroadcast();
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

    function switchSigner(address _newSigner) public {
        address foundrySigner = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
        if (msg.sender == foundrySigner) {
            vm.startPrank(_newSigner);
        } else {
            vm.stopPrank();
            vm.startPrank(_newSigner);
        }
    }
}