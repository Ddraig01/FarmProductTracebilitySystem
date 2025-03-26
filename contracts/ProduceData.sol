// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title Produce Data
 * @dev Stores data for product traceability
 */
contract ProduceData {
    struct ProductBatch {
        uint256 id;
        string name;
        string variety;
        uint256 harvestDate;
        string farmLocation;
        string farmerId;
        bool isOrganic;
        bytes32 certificateHash;
        uint256 quantity;
        string unitOfMeasure;
        mapping(uint256 => StageUpdate) supplyChainUpdates;
        uint256 updateCount;
        bool isActive;
    }

    struct StageUpdate {
        uint256 timestamp;
        string location;
        string handlerId;
        string handlerType;
        string action;
        string condition;
        string temperature;
        string humidity;
        bytes32 documentHash;
    }

    struct ProductBatchView {
        uint256 id;
        string name;
        string variety;
        uint256 harvestDate;
        string farmLocation;
        string farmerId;
        bool isOrganic;
        bytes32 certificateHash;
        uint256 quantity;
        string unitOfMeasure;
        uint256 updateCount;
        bool isActive;
    }

    uint256 public lastProductBatchId = 0;
    mapping(uint256 => ProductBatch) internal productBatches;

    event ProductBatchRegistered(uint256 batchId, string name, string farmerId);
    event ProductBatchUpdated(uint256 batchId, string handlerId, string action);

    function getProductBatchBasic(
        uint256 batchId
    ) external view virtual returns (ProductBatchView memory) {
        require(productBatches[batchId].id != 0, "Batch does not exist");

        ProductBatch storage batch = productBatches[batchId];

        return
            ProductBatchView({
                id: batch.id,
                name: batch.name,
                variety: batch.variety,
                harvestDate: batch.harvestDate,
                farmLocation: batch.farmLocation,
                farmerId: batch.farmerId,
                isOrganic: batch.isOrganic,
                certificateHash: batch.certificateHash,
                quantity: batch.quantity,
                unitOfMeasure: batch.unitOfMeasure,
                updateCount: batch.updateCount,
                isActive: batch.isActive
            });
    }

    function getProductBatchUpdate(
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
        require(productBatches[batchId].id != 0, "Batch does not exist");
        require(
            updateIndex < productBatches[batchId].updateCount,
            "Invalid update index"
        );

        StageUpdate storage update = productBatches[batchId].supplyChainUpdates[
            updateIndex
        ];

        return (
            update.timestamp,
            update.location,
            update.handlerId,
            update.handlerType,
            update.action,
            update.condition,
            update.temperature,
            update.humidity,
            update.documentHash
        );
    }
}
