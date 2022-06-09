const {upgradeProxy} = require("@openzeppelin/truffle-upgrades");

const WeddingTokenV2 = artifacts.require("WeddingTokenV2");
const WeddingTokenV3 = artifacts.require("WeddingTokenV3");


module.exports = async function (deployer, network, accounts) {
  const existing = await WeddingTokenV2.deployed();
  console.log("upgrading wedding token V2");
  const instance = await upgradeProxy(existing.address, WeddingTokenV3, {deployer: deployer});
  console.log('WeddingTokenV3 address', (await instance).address);
};
