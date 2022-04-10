const {deployProxy} = require("@openzeppelin/truffle-upgrades");

const WeddingToken = artifacts.require("WeddingToken")

module.exports = async function (deployer, network) {
  let timeout;
  switch (network) {
    case "mainnet":
      timeout = 3600*24*3;
      break;
    case "mumbai":
      timeout = 60*5;
      break;
    default:
      timeout = 4;
      break;
  }
  console.log("deploying wedding token");
  const instance = await deployProxy(WeddingToken, [timeout], {deployer: deployer});
  console.log('WeddingToken address', (await instance).address);
};
