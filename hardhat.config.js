require("@nomicfoundation/hardhat-toolbox");
require("dotenv").config();

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.28",
  networks: {
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL, // Use your Sepolia testnet RPC
      accounts: [process.env.PRIVATE_KEY], // Use your Metamask private key
    },
  },
};
