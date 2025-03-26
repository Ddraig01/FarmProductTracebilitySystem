// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./FarmerContract.sol";
import "./DistributorContract.sol";
import "./ConsumerContract.sol";

/**
 * @title Produce Traceability System
 * @dev Manages actors and allows contract upgrades
 */
contract ProduceTraceabilitySystem {
    address public owner;

    FarmerContract public farmerContract;
    DistributorContract public distributorContract;
    ConsumerContract public consumerContract;

    constructor() {
        owner = msg.sender;
        farmerContract = new FarmerContract(address(this));
        distributorContract = new DistributorContract(address(this));
        // consumerContract = new ConsumerContract(address(this));
        consumerContract = new ConsumerContract(
            address(this),
            address(farmerContract),
            address(distributorContract)
        );
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    function upgradeContract(
        uint8 contractType,
        address newContractAddress
    ) external onlyOwner {
        require(newContractAddress != address(0), "Invalid contract address");

        if (contractType == 0) {
            farmerContract = FarmerContract(newContractAddress);
        } else if (contractType == 1) {
            distributorContract = DistributorContract(newContractAddress);
        } else if (contractType == 2) {
            consumerContract = ConsumerContract(newContractAddress);
        } else {
            revert("Invalid contract type");
        }
    }
}
