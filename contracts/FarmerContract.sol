// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ProduceData.sol";

/**
 * @title Farmer Contract
 * @dev Allows farmers to register products
 */
contract FarmerContract is ProduceData {
    address public systemContract;
    mapping(address => string) public farmerIds;
    mapping(string => bool) public verifiedFarmers;

    event FarmerRegistered(address farmerAddress, string farmerId);
    event FarmerVerified(string farmerId, bool verified);

    constructor(address _systemContract) {
        systemContract = _systemContract;
    }

    modifier onlyVerifiedFarmer() {
        string memory farmerId = farmerIds[msg.sender];
        require(bytes(farmerId).length > 0, "Farmer not registered");
        require(verifiedFarmers[farmerId], "Farmer not verified");
        _;
    }

    function registerFarmer(string memory farmerId) external {
        require(
            bytes(farmerIds[msg.sender]).length == 0,
            "Farmer already registered"
        );
        farmerIds[msg.sender] = farmerId;
        verifiedFarmers[farmerId] = false;
        emit FarmerRegistered(msg.sender, farmerId);
    }

    function verifyFarmer(string memory farmerId, bool verified) external {
        require(
            msg.sender == systemContract,
            "Only system contract can verify"
        );
        verifiedFarmers[farmerId] = verified;
        emit FarmerVerified(farmerId, verified);
    }

    function registerProductBatch(
        string memory name,
        string memory variety,
        string memory farmLocation,
        bool isOrganic,
        bytes32 certificateHash,
        uint256 quantity,
        string memory unitOfMeasure
    ) external onlyVerifiedFarmer returns (uint256) {
        uint256 batchId = ++lastProductBatchId;
        ProductBatch storage newBatch = productBatches[batchId];
        newBatch.id = batchId;
        newBatch.name = name;
        newBatch.variety = variety;
        newBatch.harvestDate = block.timestamp;
        newBatch.farmLocation = farmLocation;
        newBatch.farmerId = farmerIds[msg.sender];
        newBatch.isOrganic = isOrganic;
        newBatch.certificateHash = certificateHash;
        newBatch.quantity = quantity;
        newBatch.unitOfMeasure = unitOfMeasure;
        newBatch.isActive = true;

        emit ProductBatchRegistered(batchId, name, farmerIds[msg.sender]);
        return batchId;
    }

    function getProductBatchBasic(
        uint256 batchId
    ) external view override returns (ProduceData.ProductBatchView memory) {
        require(productBatches[batchId].id != 0, "Batch does not exist");

        ProductBatch storage batch = productBatches[batchId];

        return
            ProduceData.ProductBatchView({
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
                isActive: batch.isActive,
                updateCount: batch.updateCount
            });
    }
}
