// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ProduceData.sol";
import "./FarmerContract.sol";
import "./DistributorContract.sol";

/**
 * @title Consumer Contract
 * @dev Allows consumers to verify products and submit feedback
 */
contract ConsumerContract {
    address public systemContract;
    FarmerContract public farmerContract;
    DistributorContract public distributorContract;

    // Optional mapping for registered consumers (for loyalty programs, feedback, etc.)
    mapping(address => string) public consumerIds;

    // Events
    event ProductVerified(uint256 batchId, address consumer);
    event ConsumerFeedbackSubmitted(
        uint256 batchId,
        string consumerId,
        uint8 rating,
        string feedback
    );

    constructor(
        address _systemContract,
        address _farmerContract,
        address _distributorContract
    ) {
        systemContract = _systemContract;
        farmerContract = FarmerContract(_farmerContract);
        distributorContract = DistributorContract(_distributorContract);
    }

    // Function for consumers to register (optional)
    function registerConsumer(string memory consumerId) external {
        consumerIds[msg.sender] = consumerId;
    }

    // Function for consumers to verify a product by its ID
    function verifyProduct(
        uint256 batchId
    )
        external
        returns (
            ProduceData.ProductBatchView memory batchInfo,
            uint256 totalUpdates
        )
    {
        batchInfo = farmerContract.getProductBatchBasic(batchId);
        totalUpdates = batchInfo.updateCount;

        emit ProductVerified(batchId, msg.sender);
        return (batchInfo, totalUpdates);
    }

    // Function for consumers to get a specific update in the product's history
    function getProductUpdate(
        uint256 batchId,
        uint256 updateIndex
    )
        external
        view
        returns (
            uint256 timestamp,
            string memory location,
            string memory handlerId,
            string memory handlerType,
            string memory action,
            string memory condition,
            string memory temperature,
            string memory humidity,
            bytes32 documentHash
        )
    {
        return farmerContract.getProductBatchUpdate(batchId, updateIndex);
    }

    // Function for consumers to submit feedback on a product
    function submitFeedback(
        uint256 batchId,
        uint8 rating,
        string memory feedback
    ) external {
        require(rating >= 1 && rating <= 5, "Rating must be between 1 and 5");

        // Check if the product exists
        farmerContract.getProductBatchBasic(batchId);

        string memory consumerId = consumerIds[msg.sender];
        if (bytes(consumerId).length == 0) {
            consumerId = "Anonymous";
        }

        emit ConsumerFeedbackSubmitted(batchId, consumerId, rating, feedback);
    }

    // Function to get the complete supply chain history for a product
    function getCompleteProductHistory(
        uint256 batchId
    )
        external
        view
        returns (
            ProduceData.ProductBatchView memory batchInfo,
            uint256[] memory timestamps,
            string[] memory locations,
            string[] memory handlerIds,
            string[] memory handlerTypes,
            string[] memory actions,
            string[] memory conditions
        )
    {
        batchInfo = farmerContract.getProductBatchBasic(batchId);
        uint256 updateCount = batchInfo.updateCount;

        timestamps = new uint256[](updateCount);
        locations = new string[](updateCount);
        handlerIds = new string[](updateCount);
        handlerTypes = new string[](updateCount);
        actions = new string[](updateCount);
        conditions = new string[](updateCount);

        for (uint256 i = 0; i < updateCount; i++) {
            (
                timestamps[i],
                locations[i],
                handlerIds[i],
                handlerTypes[i],
                actions[i],
                conditions[i],
                ,
                ,

            ) = farmerContract.getProductBatchUpdate(batchId, i);
        }

        return (
            batchInfo,
            timestamps,
            locations,
            handlerIds,
            handlerTypes,
            actions,
            conditions
        );
    }
}
