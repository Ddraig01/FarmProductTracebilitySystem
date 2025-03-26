// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ProduceData.sol";

/**
 * @title Distributor Contract
 * @dev Allows distributors to update product status
 */
contract DistributorContract is ProduceData {
    address public systemContract;
    mapping(address => string) public distributorIds;
    mapping(string => bool) public verifiedDistributors;

    event DistributorRegistered(
        address distributorAddress,
        string distributorId
    );
    event DistributorVerified(string distributorId, bool verified);

    constructor(address _systemContract) {
        systemContract = _systemContract;
    }

    function registerDistributor(string memory distributorId) external {
        require(
            bytes(distributorIds[msg.sender]).length == 0,
            "Distributor already registered"
        );
        distributorIds[msg.sender] = distributorId;
        verifiedDistributors[distributorId] = false;
        emit DistributorRegistered(msg.sender, distributorId);
    }

    function verifyDistributor(
        string memory distributorId,
        bool verified
    ) external {
        require(
            msg.sender == systemContract,
            "Only system contract can verify"
        );
        verifiedDistributors[distributorId] = verified;
        emit DistributorVerified(distributorId, verified);
    }

    function updateProductBatch(
        uint256 batchId,
        string memory location,
        string memory action
    ) external {
        require(
            verifiedDistributors[distributorIds[msg.sender]],
            "Only verified distributors"
        );
        ProductBatch storage batch = productBatches[batchId];
        require(batch.isActive, "Product batch not active");

        batch.updateCount++;
        emit ProductBatchUpdated(batchId, distributorIds[msg.sender], action);
    }
}
