const truffleAssert = require("truffle-assertions");

const Faucet = artifacts.require("Faucet");

const BN = web3.utils.BN;

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("Faucet", function (accounts) {
  it("open should fail if opened", async () => {
    const instance = await Faucet.deployed();
    await truffleAssert.reverts(instance.open.sendTransaction({from: accounts[0]}),
      "Faucet: opened");
  });

  it("faucet should fail with no money", async () => {
    const instance = await Faucet.deployed();
    await truffleAssert.reverts(instance.faucet.sendTransaction(accounts[0], {from: accounts[1]}),
      "Faucet: insufficient funds");
  })

  it("transfer to faucet should be successful", async () => {
    const instance = await Faucet.deployed();
    await web3.eth.sendTransaction({
      from: accounts[0],
      to: instance.address,
      value: new BN(10).pow(new BN(20))
    });
    const balance = await web3.eth.getBalance(instance.address);
    assert.equal(new BN(balance).eq(new BN(10).pow(new BN(20))), true);
  });

  it("faucet should be successful", async () => {
    const instance = await Faucet.deployed();
    const account = web3.eth.accounts.create();
    await instance.faucet(account.address, {from: accounts[1]});

    const balance = await web3.eth.getBalance(instance.address);
    assert.equal(new BN(balance).eq(new BN(999).mul(new BN(10).pow(new BN(17)))), true);

    const accountBalance = await web3.eth.getBalance(account.address);
    assert.equal(new BN(accountBalance).eq(new BN(10).pow(new BN(17))), true);

    await truffleAssert.reverts(instance.faucet.sendTransaction(account.address, {from: accounts[1]}),
      "Faucet: limit reached");

    await instance.setTotalLimit(new BN(10).pow(new BN(18)), {from: accounts[0]});

    await truffleAssert.reverts(instance.faucet.sendTransaction(account.address, {from: accounts[1]}),
      "Faucet: lock time has not expired");
  });

  it("faucet should fail after close", async () => {
    const instance = await Faucet.deployed();
    await instance.close({from: accounts[0]});

    await truffleAssert.reverts(instance.faucet.sendTransaction(accounts[0], {from: accounts[1]}),
      "Faucet: closed");
    await truffleAssert.reverts(instance.close.sendTransaction({from: accounts[0]}),
      "Faucet: closed");

    await instance.open({from: accounts[0]});
  });
})