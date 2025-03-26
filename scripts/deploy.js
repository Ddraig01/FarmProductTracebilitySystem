const hre = require("hardhat");

async function main() {
  // Get contract factories
  const FarmerContract = await hre.ethers.getContractFactory("FarmerContract");
  const DistributorContract = await hre.ethers.getContractFactory(
    "DistributorContract"
  );
  const ConsumerContract = await hre.ethers.getContractFactory(
    "ConsumerContract"
  );
  const ProduceTraceabilitySystem = await hre.ethers.getContractFactory(
    "ProduceTraceabilitySystem"
  );

  // Deploy the main system contract first
  const produceTraceabilitySystem = await ProduceTraceabilitySystem.deploy();
  await produceTraceabilitySystem.waitForDeployment();
  console.log(
    `ProduceTraceabilitySystem deployed to: ${produceTraceabilitySystem.target}`
  );

  // Deploy FarmerContract
  const farmerContract = await FarmerContract.deploy(
    produceTraceabilitySystem.target
  );
  await farmerContract.waitForDeployment();
  console.log(`FarmerContract deployed to: ${farmerContract.target}`);

  // Deploy DistributorContract
  const distributorContract = await DistributorContract.deploy(
    produceTraceabilitySystem.target
  );
  await distributorContract.waitForDeployment();
  console.log(`DistributorContract deployed to: ${distributorContract.target}`);

  // Deploy ConsumerContract (PASS ALL THREE ARGUMENTS)
  const consumerContract = await ConsumerContract.deploy(
    produceTraceabilitySystem.target,
    farmerContract.target,
    distributorContract.target
  );
  await consumerContract.waitForDeployment();
  console.log(`ConsumerContract deployed to: ${consumerContract.target}`);
}

// Run deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
