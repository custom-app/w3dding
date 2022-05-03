const {deployProxy} = require("@openzeppelin/truffle-upgrades");

const Faucet = artifacts.require("Faucet");
const BN = web3.utils.BN;

module.exports = async function(deployer, network, accounts) {
  let faucetAccount;
  switch (network) {
    case "mainnet":
      faucetAccount = process.env.W3DDING_MAINNET_FAUCET_ACCOUNT
      break;
    case "mumbai":
      faucetAccount = process.env.W3DDING_TESTNET_FAUCET_ACCOUNT
      break;
    default:
      faucetAccount = accounts[1];
      break;
  }
  const faucet = await deployProxy(Faucet,
    [faucetAccount, new BN(10).pow(new BN(17)), new BN(10).pow(new BN(17))], {deployer: deployer});
  console.log("Faucet address", faucet.address);
};
