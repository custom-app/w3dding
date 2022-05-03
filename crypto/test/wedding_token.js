const truffleAssert = require("truffle-assertions");
const sha256 = require("js-sha256").sha256;

const WeddingToken = artifacts.require("WeddingTokenV3");

const BN = web3.utils.BN;

/*
 * uncomment accounts to access the test accounts made available by the
 * Ethereum client
 * See docs: https://www.trufflesuite.com/docs/truffle/testing/writing-tests-in-javascript
 */
contract("WeddingToken", function (accounts) {
  it("should assert true", async function () {
    await WeddingToken.deployed();
    return assert.isTrue(true);
  });

  it("default timeout should be 5", async () => {
    const instance = await WeddingToken.deployed();
    const defaultTimeout = await instance.defaultDivorceTimeout();
    return assert.equal(defaultTimeout, 4);
  });

  it("marry yourself should failed", async () => {
    const instance = await WeddingToken.deployed();
    await truffleAssert.reverts(instance.propose.sendTransaction(accounts[0], "", "", {from: accounts[0]}),
      "WeddingToken: cannot mary yourself");
  });

  it("update proposition should fail if not exist", async () => {
    const instance = await WeddingToken.deployed();
    await truffleAssert.reverts(instance.updateProposition.sendTransaction(accounts[1], "", "", {from: accounts[0]}),
      "WeddingToken: proposition doesn't exist");
  });

  it("accept proposition should fail if not exist", async () => {
    const instance = await WeddingToken.deployed();
    await truffleAssert.reverts(instance.acceptProposition.sendTransaction(accounts[1], "0x", "0x", {from: accounts[0]}),
      "WeddingToken: proposition doesn't exist");
  });

  it("divorce should fail if not in marriage", async () => {
    const instance = await WeddingToken.deployed();
    await truffleAssert.reverts(instance.requestDivorce.sendTransaction({from: accounts[0]}),
      "WeddingToken: not in marriage");
  });

  it("divorce confirm should fail if not in marriage", async () => {
    const instance = await WeddingToken.deployed();
    await truffleAssert.reverts(instance.confirmDivorce.sendTransaction({from: accounts[0]}),
      "WeddingToken: not in marriage");
  });

  it("propose should be successful", async () => {
    const instance = await WeddingToken.deployed();
    const tx = await instance.propose.sendTransaction(accounts[1], "some link", "some data", {from: accounts[0]});
    await truffleAssert.eventEmitted(tx, "Proposition", (ev) => {
      return ev.from.toLowerCase() === accounts[0].toLowerCase() &&
        ev.to.toLowerCase() === accounts[1].toLowerCase() && new BN(ev.id).eq(new BN(1)) &&
        ev.metaUri === "some link" && ev.condData === "some data" && ev.authorAccepted && !ev.receiverAccepted;
    });
  });

  it("should be able to send other proposition", async () => {
    const instance = await WeddingToken.deployed();
    const tx = await instance.propose.sendTransaction(accounts[2], "some link", "some data", {from: accounts[0]});
    await truffleAssert.eventEmitted(tx, "Proposition", (ev) => {
      return ev.from.toLowerCase() === accounts[0].toLowerCase() &&
        ev.to.toLowerCase() === accounts[2].toLowerCase() && new BN(ev.id).eq(new BN(2)) &&
        ev.metaUri === "some link" && ev.condData === "some data" && ev.authorAccepted && !ev.receiverAccepted;
    });
  });

  it("proposition should be accessible", async () => {
    const instance = await WeddingToken.deployed();
    const prop = await instance.propositions(accounts[0], accounts[1]);
    assert.equal(prop.metaUri, "some link");
    assert.equal(prop.conditionsData, "some data");
    assert.equal(prop.divorceTimeout.eq(new BN(4)), true);
    assert.equal(prop.authorAccepted, true);
    assert.equal(prop.receiverAccepted, false);
    assert.equal(new BN(prop.tokenId).eq(new BN(1)), true);
    assert.equal(new BN(prop.prevBlockNumber).gt(new BN(0)), true);
  });

  it("should fail when proposition exists", async () => {
    const instance = await WeddingToken.deployed();
    await truffleAssert.reverts(instance.propose.sendTransaction(accounts[1], "", "", {from: accounts[0]}),
      "WeddingToken: proposition exists");
  });

  it("accept should be disabled for already accepted", async () => {
    const instance = await WeddingToken.deployed();
    await truffleAssert.reverts(instance.acceptProposition.sendTransaction(accounts[1], "0x", "0x", {from: accounts[0]}),
      "WeddingToken: accept from partner required");
  });

  it("proposition should be updatable by author", async () => {
    const instance = await WeddingToken.deployed();
    const tx = await instance.updateProposition.sendTransaction(accounts[1],
      "new link", "new data", {from: accounts[0]});
    await truffleAssert.eventEmitted(tx, "Proposition", (ev) => {
      return ev.from.toLowerCase() === accounts[0].toLowerCase() &&
        ev.to.toLowerCase() === accounts[1].toLowerCase() && new BN(ev.id).eq(new BN(1)) &&
        ev.metaUri === "new link" && ev.condData === "new data" && ev.authorAccepted && !ev.receiverAccepted;
    });

    const prop = await instance.propositions(accounts[0], accounts[1]);
    assert.equal(prop.metaUri, "new link");
    assert.equal(prop.conditionsData, "new data");
    assert.equal(prop.divorceTimeout.eq(new BN(4)), true);
    assert.equal(prop.authorAccepted, true);
    assert.equal(prop.receiverAccepted, false);
    assert.equal(new BN(prop.tokenId).eq(new BN(1)), true);
    assert.equal(new BN(prop.prevBlockNumber).gt(new BN(0)), true);
  });

  it("accept should be disabled for already accepted 2", async () => {
    const instance = await WeddingToken.deployed();
    await truffleAssert.reverts(instance.acceptProposition.sendTransaction(accounts[1], "0x", "0x", {from: accounts[0]}),
      "WeddingToken: accept from partner required");
  });

  it("proposition should be updatable by receiver", async () => {
    const instance = await WeddingToken.deployed();
    const tx = await instance.updateProposition.sendTransaction(accounts[0],
      "new link 2", "new data 2", {from: accounts[1]});
    await truffleAssert.eventEmitted(tx, "Proposition", (ev) => {
      return ev.from.toLowerCase() === accounts[0].toLowerCase() &&
        ev.to.toLowerCase() === accounts[1].toLowerCase() && new BN(ev.id).eq(new BN(1)) &&
        ev.metaUri === "new link 2" && ev.condData === "new data 2" && !ev.authorAccepted && ev.receiverAccepted;
    });

    const prop = await instance.propositions(accounts[0], accounts[1]);
    assert.equal(prop.metaUri, "new link 2");
    assert.equal(prop.conditionsData, "new data 2");
    assert.equal(prop.divorceTimeout.eq(new BN(4)), true);
    assert.equal(prop.authorAccepted, false);
    assert.equal(prop.receiverAccepted, true);
    assert.equal(new BN(prop.tokenId).eq(new BN(1)), true);
    assert.equal(new BN(prop.prevBlockNumber).gt(new BN(0)), true);
  });

  it("incoming propositions should be correct", async () => {
    const instance = await WeddingToken.deployed();
    const incoming = await instance.getIncomingPropositions({from: accounts[1]});
    assert.equal(incoming[0].length, 1);
    assert.equal(incoming[0][0].toLowerCase(), accounts[0].toLowerCase());
    assert.equal(incoming[1].length, 1);
    assert.equal(incoming[1][0].metaUri, "new link 2");
    assert.equal(incoming[1][0].conditionsData, "new data 2");
    assert.equal(new BN(incoming[1][0].divorceTimeout).eq(new BN(4)), true);
    assert.equal(incoming[1][0].authorAccepted, false);
    assert.equal(incoming[1][0].receiverAccepted, true);
    assert.equal(new BN(incoming[1][0].tokenId).eq(new BN(1)), true);
    assert.equal(new BN(incoming[1][0].prevBlockNumber).gt(new BN(0)), true);
  });

  it("outgoing propositions should be correct", async () => {
    const instance = await WeddingToken.deployed();
    const outgoing = await instance.getOutgoingPropositions({from: accounts[0]});
    const addresses = [accounts[1].toLowerCase(), accounts[2].toLowerCase()];
    const props = [
      {
        metaUri: "new link 2",
        conditionsData: "new data 2",
        divorceTimeout: "4",
        authorAccepted: false,
        receiverAccepted: true,
        tokenId: "1",
      },
      {
        metaUri: "some link",
        conditionsData: "some data",
        divorceTimeout: "4",
        authorAccepted: true,
        receiverAccepted: false,
        tokenId: "2",
      }
    ];
    assert.equal(outgoing[0].length, 2);
    assert.equal(outgoing[1].length, 2);
    if (outgoing[0][0].toLowerCase() !== addresses[0]) {
      const a = addresses[0];
      addresses[0] = addresses[1];
      addresses[1] = a;
      const p = props[0];
      props[0] = props[1];
      props[1] = p;
    }
    for (let i = 0; i < 2; i++) {
      assert.equal(outgoing[0][i].toLowerCase(), addresses[i].toLowerCase());
      assert.equal(outgoing[1][i].metaUri, props[i].metaUri);
      assert.equal(outgoing[1][i].conditionsData, props[i].conditionsData);
      assert.equal(new BN(outgoing[1][i].divorceTimeout).eq(new BN(props[i].divorceTimeout)), true);
      assert.equal(outgoing[1][i].authorAccepted, props[i].authorAccepted);
      assert.equal(outgoing[1][i].receiverAccepted, props[i].receiverAccepted);
      assert.equal(new BN(outgoing[1][i].tokenId).eq(new BN(props[i].tokenId)), true);
      assert.equal(new BN(outgoing[1][i].prevBlockNumber).gt(new BN(0)), true);
    }
  });

  it("accept should be disabled for already accepted 3", async () => {
    const instance = await WeddingToken.deployed();
    await truffleAssert.reverts(instance.acceptProposition.sendTransaction(accounts[0], "0x", "0x", {from: accounts[1]}),
      "WeddingToken: accept from partner required");
  });

  it("accept should be successful", async () => {
    const instance = await WeddingToken.deployed();
    const tx = await instance.acceptProposition(accounts[1], "0x" + sha256("new link 2"),
      "0x" + sha256("new data 2"), {from: accounts[0]});
    await truffleAssert.eventEmitted(tx, "Wedding", (ev) => {
      return ev.author.toLowerCase() === accounts[0].toLowerCase() &&
        ev.receiver.toLowerCase() === accounts[1].toLowerCase() && new BN(ev.id).eq(new BN(1)) &&
        ev.metaUri === "new link 2" && ev.condData === "new data 2";
    });
  });

  it("wedding should be accessible", async () => {
    const instance = await WeddingToken.deployed();
    const weddings = [];
    weddings[0] = await instance.getCurrentMarriage({from: accounts[0]});
    weddings[1] = await instance.getCurrentMarriage({from: accounts[1]});
    for (let i = 0; i < weddings.length; i++) {
      const wedding = weddings[i];
      assert.equal(wedding.author.toLowerCase(), accounts[0].toLowerCase());
      assert.equal(wedding.receiver.toLowerCase(), accounts[1].toLowerCase());
      assert.equal(wedding.metaUri, "new link 2");
      assert.equal(wedding.conditionsData, "new data 2");
      assert.equal(new BN(wedding.divorceTimeout).eq(new BN(4)), true);
      assert.equal(new BN(wedding.divorceRequestTimestamp).eq(new BN(0)), true);
      assert.equal(wedding.divorceState, "0");
      assert.equal(new BN(wedding.tokenId).eq(new BN(1)), true);
    }
  });

  it("proposition should not be acceptable in case of marriage of partner", async () => {
    const instance = await WeddingToken.deployed();
    await truffleAssert.reverts(instance.acceptProposition.sendTransaction(accounts[0], "0x", "0x", {from: accounts[2]}),
      "WeddingToken: partner already in marriage");
  });

  it("creating propositions should be disabled for married", async () => {
    const instance = await WeddingToken.deployed();
    await truffleAssert.reverts(instance.propose.sendTransaction(accounts[1], "", "", {from: accounts[0]}),
      "WeddingToken: already in marriage");
  });

  it("updating propositions should be disabled for married", async () => {
    const instance = await WeddingToken.deployed();
    await truffleAssert.reverts(instance.updateProposition.sendTransaction(accounts[1], "", "", {from: accounts[0]}),
      "WeddingToken: already in marriage");
  });

  it("accepting propositions should be disabled for married", async () => {
    const instance = await WeddingToken.deployed();
    await truffleAssert.reverts(instance.acceptProposition.sendTransaction(accounts[1], "0x", "0x", {from: accounts[0]}),
      "WeddingToken: already in marriage");
  });

  it("confirm divorce should fail if not requested", async () => {
    const instance = await WeddingToken.deployed();
    await truffleAssert.reverts(instance.confirmDivorce.sendTransaction({from: accounts[0]}),
      "WeddingToken: divorce wasn't requested");
  });

  it("divorce request should be successful", async () => {
    const instance = await WeddingToken.deployed();
    const tx = await instance.requestDivorce({from: accounts[0]});
    await truffleAssert.eventEmitted(tx, "DivorceRequest", (ev) => {
      return ev.author.toLowerCase() === accounts[0].toLowerCase() &&
        ev.receiver.toLowerCase() === accounts[1].toLowerCase() && new BN(ev.id).eq(new BN(1))
        && new BN(ev.timeout).eq(new BN(4)) && ev.byAuthor;
    });
    const wedding = await instance.getCurrentMarriage({from: accounts[0]});
    assert.equal(wedding.author.toLowerCase(), accounts[0].toLowerCase());
    assert.equal(wedding.receiver.toLowerCase(), accounts[1].toLowerCase());
    assert.equal(wedding.metaUri, "new link 2");
    assert.equal(wedding.conditionsData, "new data 2");
    assert.equal(new BN(wedding.divorceTimeout).eq(new BN(4)), true);
    assert.equal(wedding.divorceState, "1");
    assert.equal(new BN(wedding.tokenId).eq(new BN(1)), true);
  });

  it("divorce rerequest should fail", async () => {
    const instance = await WeddingToken.deployed();
    await truffleAssert.reverts(instance.requestDivorce.sendTransaction({from: accounts[0]}),
      "WeddingToken: divorce already requested");
  })

  it("divorce should fail without timeout", async () => {
    const instance = await WeddingToken.deployed();
    await truffleAssert.reverts(instance.confirmDivorce.sendTransaction({from: accounts[0]}),
      "WeddingToken: divorce confirmation not allowed");
  });

  it("accept divorce should be successful", async () => {
    const instance = await WeddingToken.deployed();
    const tx = await instance.confirmDivorce.sendTransaction({from: accounts[1]});
    await truffleAssert.eventEmitted(tx, "Divorce", (ev) => {
      return ev.author.toLowerCase() === accounts[0].toLowerCase() &&
        ev.receiver.toLowerCase() === accounts[1].toLowerCase() && new BN(ev.id).eq(new BN(1));
    });
  });

  function sleep(ms) {
    return new Promise(resolve => setTimeout(resolve, ms));
  }

  it("accept divorce after timeout should be successful", async () => {
    const instance = await WeddingToken.deployed();
    await instance.acceptProposition.sendTransaction(accounts[0], "0x" + sha256("some link"),
      "0x" + sha256("some data"), {from: accounts[2]});
    await instance.requestDivorce({from: accounts[2]});
    await sleep(5000);
    const tx = await instance.confirmDivorce.sendTransaction({from: accounts[2], gas: 5000000});
    await truffleAssert.eventEmitted(tx, "Divorce", (ev) => {
      return ev.author.toLowerCase() === accounts[0].toLowerCase() &&
        ev.receiver.toLowerCase() === accounts[2].toLowerCase() && new BN(ev.id).eq(new BN(2));
    });
  });
});
