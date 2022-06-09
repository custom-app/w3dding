const {upgradeProxy} = require("@openzeppelin/truffle-upgrades");

const WeddingToken = artifacts.require("WeddingToken");
const WeddingTokenV2 = artifacts.require("WeddingTokenV2");

module.exports = async function (deployer, network, accounts) {
  const existing = await WeddingToken.deployed();
  console.log("upgrading wedding token");
  const instance = await upgradeProxy(existing.address, WeddingTokenV2, {deployer: deployer});
  console.log('WeddingTokenV2 address', (await instance).address);
  if (network === "mumbai") {
    await instance.setContractUri(process.env.W3DDING_TESTNET_CONTRACT_URI, {from: accounts[0]});
  } else {
    await instance.setContractUri(process.env.W3DDING_MAINNET_CONTRACT_URI, {from: accounts[0]});
  }
};
