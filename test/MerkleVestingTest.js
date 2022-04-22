const { BigNumber, constants } = require("ethers");
const { BN, time, expectRevert, expectEvent } = require("@openzeppelin/test-helpers");
const expect = require("chai").expect;
const { tsImport } = require("ts-import");

const Vesting = artifacts.require("MerkleVesting");
const ERC20MintableBurnable = artifacts.require("ERC20MintableBurnable");

// ts imports
async function importTs() {
  const filePath1 = "./scripts/merkleTree/balance-tree.ts";
  BalanceTree = await tsImport.compile(filePath1);
}

let BalanceTree;

const randomVestingPeriod = 43200;
const randomCliff = 120;
const randomRoot0 = "0xf7f77ea15719ea30bd2a584962ab273b1116f0e70fe80bbb0b30557d0addb7f3";
const randomRoot1 = "0xcb676dae3fc411069ab10b651ba8fb3658ed4bd41d7dc5add6d7f120e51eb7f7";

async function setBalance(token, to, amount) {
  const old = await token.balanceOf(to);
  if (old.lt(amount)) await token.mint(to, amount.sub(old));
  else if (old.gt(amount)) await token.burn(to, old.sub(amount));
}

async function getClaimableAmount(vesting, cohortId, account, fullAmount) {
  const cohort = await vesting.getCohort(cohortId);
  const claimedSoFar = await vesting.getClaimed(cohortId, account);
  const vestingPeriod = new BN(cohort.vestingPeriod);
  const vestingEnd = vestingPeriod.add(new BN(cohort.distributionStart));
  const vestingStart = new BN(cohort.distributionStart);
  const cliff = vestingStart.add(new BN(cohort.cliffPeriod));
  const timestamp = await time.latest();
  if (timestamp.lt(cliff)) process.exit(1);
  else if (timestamp.lt(vestingEnd))
    return fullAmount.mul(timestamp.sub(vestingStart)).div(vestingPeriod).sub(claimedSoFar);
  else return fullAmount.sub(claimedSoFar);
}

contract("MerkleVesting", function (accounts) {
  const [wallet0, wallet1] = accounts;
  const distributionDuration = 86400;
  let token;

  before("import ts libs", async function () {
    await importTs();
  });

  beforeEach("deploy token", async function () {
    token = await ERC20MintableBurnable.new("OwoToken", "OWO", 18, wallet0, 0);
  });

  context("#token", function () {
    it("returns the token address", async function () {
      const vesting = await Vesting.new(token.address, wallet0);
      expect(await vesting.token()).to.eq(token.address);
    });
  });

  context("#addCohort && #getCohort", function () {
    it("fails if not called by the owner", async function () {
      const vesting = await Vesting.new(token.address, wallet1);
      await expectRevert(
        vesting.addCohort(randomRoot0, 0, distributionDuration, randomVestingPeriod, randomCliff),
        "Ownable: caller is not the owner"
      );
    });

    it("fails if called with invalid parameters", async function () {
      const vesting = await Vesting.new(token.address, wallet0);
      // error InvalidParameters();
      await expectRevert.unspecified(
        vesting.addCohort(constants.HashZero, 0, distributionDuration, randomVestingPeriod, randomCliff)
      );
      await expectRevert.unspecified(vesting.addCohort(randomRoot0, 0, 0, randomVestingPeriod, randomCliff));
      await expectRevert.unspecified(vesting.addCohort(randomRoot0, 0, distributionDuration, 0, randomCliff));
    });

    it("fails when trying to create two cohorts with the same root", async function () {
      const vesting = await Vesting.new(token.address, wallet0);
      await vesting.addCohort(randomRoot0, 0, distributionDuration, randomVestingPeriod, randomCliff);
      // error MerkleRootCollision();
      await expectRevert.unspecified(
        vesting.addCohort(randomRoot0, 0, distributionDuration, randomVestingPeriod, randomCliff)
      );
    });

    it("fails when cliff < vesting < distribution is not true", async function () {
      const vesting = await Vesting.new(token.address, wallet0);
      // error InvalidParameters();
      await expectRevert.unspecified(
        vesting.addCohort(randomRoot0, 0, randomVestingPeriod, distributionDuration, randomCliff)
      );
      await expectRevert.unspecified(
        vesting.addCohort(randomRoot0, 0, randomCliff, distributionDuration, randomVestingPeriod)
      );
      await expectRevert.unspecified(
        vesting.addCohort(randomRoot0, 0, distributionDuration, randomCliff, randomVestingPeriod)
      );
    });

    it("fails when trying to add a cohort that's already ended", async function () {
      const vesting = await Vesting.new(token.address, wallet0);
      // error DistributionOngoing(uint256 current, uint256 end);
      await expectRevert.unspecified(
        vesting.addCohort(randomRoot0, 1, randomVestingPeriod, distributionDuration, randomCliff)
      );
    });

    it("updates lastEndingCohort if needed", async function () {
      const vesting = await Vesting.new(token.address, wallet0);
      const lastEndingCohort0 = await vesting.lastEndingCohort();
      await vesting.addCohort(randomRoot0, 0, distributionDuration, randomVestingPeriod, randomCliff);
      const lastEndingCohort1 = await vesting.lastEndingCohort();
      await vesting.addCohort(randomRoot1, 0, distributionDuration - 1, randomVestingPeriod, randomCliff);
      const lastEndingCohort2 = await vesting.lastEndingCohort();
      expect(lastEndingCohort0).to.eq(constants.HashZero);
      expect(lastEndingCohort1).to.eq(randomRoot0);
      expect(lastEndingCohort2).to.eq(randomRoot0);
    });

    it("sets the cohort data correctly", async function () {
      const vesting = await Vesting.new(token.address, wallet0);
      const timestamp = await time.latest();
      await vesting.addCohort(randomRoot0, timestamp, distributionDuration, randomVestingPeriod, randomCliff);
      const cohort = await vesting.getCohort(randomRoot0);
      expect(cohort.merkleRoot).to.eq(randomRoot0);
      expect(cohort.distributionStart).to.bignumber.eq(timestamp);
      expect(cohort.distributionEnd).to.bignumber.eq(timestamp.add(new BN(distributionDuration)));
      expect(cohort.vestingPeriod).to.bignumber.eq(randomVestingPeriod.toString());
      expect(cohort.cliffPeriod).to.bignumber.eq(randomCliff.toString());
    });

    it("emits CohortAdded event", async function () {
      const vesting = await Vesting.new(token.address, wallet0);
      const result0 = await vesting.addCohort(randomRoot0, 0, distributionDuration, randomVestingPeriod, randomCliff);
      await expectEvent(result0, "CohortAdded", { cohortId: randomRoot0 });
      const result1 = await vesting.addCohort(randomRoot1, 0, distributionDuration, randomVestingPeriod, randomCliff);
      await expectEvent(result1, "CohortAdded", { cohortId: randomRoot1 });
    });
  });

  context("disabled state management", function () {
    let vesting;

    beforeEach("create a cohort", async function () {
      vesting = await Vesting.new(token.address, wallet0);
      await vesting.addCohort(randomRoot0, 0, distributionDuration, randomVestingPeriod, randomCliff);
    });

    it("fails if not called by the owner", async function () {
      await expectRevert(vesting.setDisabled(randomRoot0, 0, { from: wallet1 }), "Ownable: caller is not the owner");
    });

    it("sets and gets the disabled state correctly", async function () {
      const old0 = await vesting.isDisabled(randomRoot0, 0);
      const old1 = await vesting.isDisabled(randomRoot0, 240);
      const old2 = await vesting.isDisabled(randomRoot0, 260);
      const old3 = await vesting.isDisabled(randomRoot0, 285);
      await vesting.setDisabled(randomRoot0, 0); // 0
      await vesting.setDisabled(randomRoot0, 260); // 2
      const new0 = await vesting.isDisabled(randomRoot0, 0);
      const new1 = await vesting.isDisabled(randomRoot0, 240);
      const new2 = await vesting.isDisabled(randomRoot0, 260);
      const new3 = await vesting.isDisabled(randomRoot0, 285);
      expect(old0).to.be.false;
      expect(new0).to.be.true;
      expect(new1).to.eq(old1);
      expect(old2).to.be.false;
      expect(new2).to.be.true;
      expect(new3).to.eq(old3);
    });
  });

  context("#claim", function () {
    it("fails for invalid cohortId", async function () {
      const vesting = await Vesting.new(token.address, wallet0);
      await vesting.addCohort(randomRoot0, 0, distributionDuration, randomVestingPeriod, randomCliff);
      // error CohortDoesNotExist();
      await expectRevert.unspecified(vesting.claim(constants.HashZero, 0, wallet0, 10, []));
      await expectRevert.unspecified(vesting.claim(randomRoot1, 0, wallet0, 10, []));
    });

    it("fails if distribution ended", async function () {
      const vesting = await Vesting.new(token.address, wallet0);
      await vesting.addCohort(randomRoot0, 0, distributionDuration, randomVestingPeriod, randomCliff);
      await time.increase(distributionDuration + 1);
      // error DistributionEnded(uint256 current, uint256 end);
      await expectRevert.unspecified(vesting.claim(randomRoot0, 0, wallet0, 10, []));
    });

    it("fails if distribution has not started yet", async function () {
      const vesting = await Vesting.new(token.address, wallet0);
      const timestamp = await time.latest();
      await vesting.addCohort(
        randomRoot0,
        timestamp.add(new BN(120)),
        distributionDuration,
        randomVestingPeriod,
        randomCliff
      );
      // error DistributionNotStarted(uint256 current, uint256 start);
      await expectRevert.unspecified(vesting.claim(randomRoot0, 0, wallet0, 10, []));
    });

    context("two account tree", function () {
      let vesting;
      let tree;
      let root;

      before("create tree", function () {
        tree = new BalanceTree.default([
          { account: wallet0, amount: BigNumber.from(100) },
          { account: wallet1, amount: BigNumber.from(101) }
        ]);
        root = tree.getHexRoot();
      });

      beforeEach("deploy", async function () {
        vesting = await Vesting.new(token.address, wallet0);
        await vesting.addCohort(root, 0, distributionDuration, randomVestingPeriod, randomCliff);
        await setBalance(token, vesting.address, new BN(201));
      });

      it("fails for empty proof", async function () {
        // error InvalidProof();
        await expectRevert.unspecified(vesting.claim(root, 0, wallet0, 10, []));
      });

      it("fails for invalid index", async function () {
        // error InvalidProof();
        await expectRevert.unspecified(vesting.claim(root, 0, wallet0, 10, []));
      });

      it("fails when trying to claim before the cliff", async function () {
        const proof0 = tree.getProof(0, wallet0, BigNumber.from(100));
        // error CliffNotReached(uint256 cliff, uint256 timestamp);
        await expectRevert.unspecified(vesting.claim(root, 0, wallet0, 100, proof0));
      });

      it("fails if the address is disabled", async function () {
        const proof0 = tree.getProof(0, wallet0, BigNumber.from(100));
        await time.increase(randomCliff + 1);
        await vesting.setDisabled(root, 0);
        // error NotInVesting(bytes32 cohortId, address account);
        await expectRevert.unspecified(vesting.claim(root, 0, wallet0, 100, proof0));
      });

      it("correctly calculates the claimable amount", async function () {
        const fullAmount = new BN(100);
        await time.increase(randomCliff + randomVestingPeriod / 2);
        const proof0 = tree.getProof(0, wallet0, BigNumber.from(fullAmount.toString()));
        expect(await vesting.getClaimableAmount(root, 0, wallet0, fullAmount)).to.bignumber.eq(
          await getClaimableAmount(vesting, root, wallet0, fullAmount)
        );
        await vesting.claim(root, 0, wallet0, 100, proof0);
        expect(await vesting.getClaimableAmount(root, 0, wallet0, fullAmount)).to.bignumber.eq("0");
      });

      it("successful claim", async function () {
        await time.increase(randomCliff + 1);
        const proof0 = tree.getProof(0, wallet0, BigNumber.from(100));
        const claimableAmount0 = await getClaimableAmount(vesting, root, wallet0, new BN(100));
        const result0 = await vesting.claim(root, 0, wallet0, 100, proof0);
        await expectEvent(result0, "Claimed", { cohortId: root, account: wallet0, amount: claimableAmount0 });
        const proof1 = tree.getProof(1, wallet1, BigNumber.from(101));
        const claimableAmount1 = await getClaimableAmount(vesting, root, wallet1, new BN(101));
        const result1 = await vesting.claim(root, 1, wallet1, 101, proof1);
        await expectEvent(result1, "Claimed", { cohortId: root, account: wallet1, amount: claimableAmount1 });
      });

      it("transfers the token", async function () {
        await time.increase(randomCliff + 1);
        const proof0 = tree.getProof(0, wallet0, BigNumber.from(100));
        expect(await token.balanceOf(wallet0)).to.bignumber.eq("0");
        await time.increase(randomVestingPeriod + 1);
        await vesting.claim(root, 0, wallet0, 100, proof0);
        expect(await token.balanceOf(wallet0)).to.bignumber.eq("100");
      });

      it("must have enough to transfer", async function () {
        await time.increase(randomCliff + 1);
        const proof0 = tree.getProof(0, wallet0, BigNumber.from(100));
        await setBalance(token, vesting.address, new BN(1));
        await time.increase(randomVestingPeriod);
        await expectRevert(vesting.claim(root, 0, wallet0, 100, proof0), "ERC20: transfer amount exceeds balance");
      });

      it("sets #getClaimed", async function () {
        await time.increase(randomCliff + 1);
        await vesting.addCohort(randomRoot0, 0, distributionDuration, randomVestingPeriod, randomCliff); // second cohort
        const proof0 = tree.getProof(0, wallet0, BigNumber.from(100));
        expect(await vesting.getClaimed(root, wallet0)).to.bignumber.eq("0");
        expect(await vesting.getClaimed(randomRoot0, wallet0)).to.bignumber.eq("0");
        await time.increase(randomVestingPeriod + 1);
        await vesting.claim(root, 0, wallet0, 100, proof0);
        expect(await vesting.getClaimed(root, wallet0)).to.bignumber.eq("100");
        expect(await vesting.getClaimed(randomRoot0, wallet0)).to.bignumber.eq("0");
      });

      it("does allow subsequent claims", async function () {
        await time.increase(randomCliff + 1);
        const proof0 = tree.getProof(0, wallet0, BigNumber.from(100));
        const res0 = await vesting.claim(root, 0, wallet0, 100, proof0);
        const res1 = await vesting.claim(root, 0, wallet0, 100, proof0);
        expect(res0.receipt.status).to.eq(true);
        expect(res1.receipt.status).to.eq(true);
      });

      it("cannot claim for address other than proof", async function () {
        await time.increase(randomCliff + 1);
        const proof0 = tree.getProof(0, wallet0, BigNumber.from(100));
        // error InvalidProof();
        await expectRevert.unspecified(vesting.claim(root, 1, wallet1, 101, proof0));
      });

      it("cannot claim more with one proof", async function () {
        await time.increase(randomCliff + 1);
        const proof0 = tree.getProof(0, wallet0, BigNumber.from(100));
        // error InvalidProof();
        await expectRevert.unspecified(vesting.claim(root, 0, wallet0, 101, proof0));
      });
    });

    context("larger tree", function () {
      let vesting;
      let tree;
      let root;

      before("create tree", function () {
        tree = new BalanceTree.default(
          accounts.map((wallet, ix) => {
            return { account: wallet, amount: BigNumber.from(ix + 1) };
          })
        );
        root = tree.getHexRoot();
      });

      beforeEach("deploy", async function () {
        vesting = await Vesting.new(token.address, wallet0);
        await vesting.addCohort(root, 0, distributionDuration, randomVestingPeriod, 0);
        await setBalance(token, vesting.address, new BN(201));
      });

      it("claim index 4", async function () {
        const proof = tree.getProof(4, accounts[4], BigNumber.from(5));
        const claimableAmount = await getClaimableAmount(vesting, root, accounts[4], new BN(5));
        const result = await vesting.claim(root, 4, accounts[4], 5, proof);
        await expectEvent(result, "Claimed", { cohortId: root, account: accounts[4], amount: claimableAmount });
      });

      it("claim index 9", async function () {
        const proof = tree.getProof(9, accounts[9], BigNumber.from(10));
        const claimableAmount = await getClaimableAmount(vesting, root, accounts[9], new BN(10));
        const result = await vesting.claim(root, 9, accounts[9], 10, proof);
        await expectEvent(result, "Claimed", { cohortId: root, account: accounts[9], amount: claimableAmount });
      });
    });

    context("realistic size tree", function () {
      let tree;
      let root;
      const NUM_LEAVES = 100_000;
      const NUM_SAMPLES = 25;
      const elements = [];

      before("create tree", function () {
        for (let i = 0; i < NUM_LEAVES; i++) {
          const node = { account: wallet0, amount: BigNumber.from(100) };
          elements.push(node);
        }
        tree = new BalanceTree.default(elements);
        root = tree.getHexRoot();
      });

      it("proof verification works", function () {
        const convRoot = Buffer.from(root.slice(2), "hex");
        for (let i = 0; i < NUM_LEAVES; i += NUM_LEAVES / NUM_SAMPLES) {
          const proof = tree.getProof(i, wallet0, BigNumber.from(100)).map((el) => Buffer.from(el.slice(2), "hex"));
          const validProof = BalanceTree.default.verifyProof(i, wallet0, BigNumber.from(100), proof, convRoot);
          expect(validProof).to.be.true;
        }
      });

      it("subsequent claims in random distribution", async function () {
        const vesting = await Vesting.new(token.address, wallet0);
        await vesting.addCohort(root, 0, distributionDuration, randomVestingPeriod, 0);
        await setBalance(token, vesting.address, new BN(100000000));
        for (let i = 0; i < 25; i += Math.floor(Math.random() * (NUM_LEAVES / NUM_SAMPLES))) {
          const proof = tree.getProof(i, wallet0, BigNumber.from(100));
          const res0 = await vesting.claim(root, i, wallet0, 100, proof);
          const res1 = await vesting.claim(root, i, wallet0, 100, proof);
          expect(res0.receipt.status).to.eq(true);
          expect(res1.receipt.status).to.eq(true);
        }
      });
    });
  });

  context("#prolongDistributionPeriod", async function () {
    let vesting;
    let tree;
    let root;

    before("create tree", function () {
      tree = new BalanceTree.default([
        { account: wallet0, amount: BigNumber.from(100) },
        { account: wallet1, amount: BigNumber.from(101) }
      ]);
      root = tree.getHexRoot();
    });

    beforeEach("deploy contract", async function () {
      vesting = await Vesting.new(token.address, wallet0);
      await vesting.addCohort(root, 0, distributionDuration, randomVestingPeriod, randomCliff);
      await setBalance(token, vesting.address, new BN(101));
    });

    it("fails if not called by the owner", async function () {
      await expectRevert(
        vesting.prolongDistributionPeriod(root, 990, { from: wallet1 }),
        "Ownable: caller is not the owner"
      );
    });

    it("sets a new, higher distibution end", async function () {
      const addition = new BN(distributionDuration);
      const oldCohort = await vesting.getCohort(root);
      const oldPeriod = new BN(oldCohort.distributionEnd);
      await vesting.prolongDistributionPeriod(root, addition);
      const newCohort = await vesting.getCohort(root);
      const newPeriod = newCohort.distributionEnd;
      expect(newPeriod).to.bignumber.eq(oldPeriod.add(addition));
    });

    it("allows claiming with a new distribution period", async function () {
      await setBalance(token, vesting.address, new BN(101));
      const proof0 = tree.getProof(0, wallet0, BigNumber.from(100));
      await time.increase(new BN(distributionDuration).add(new BN(120)));
      // error DistributionEnded(uint256 current, uint256 end);
      await expectRevert.unspecified(vesting.claim(root, 0, wallet0, 100, proof0));
      await vesting.prolongDistributionPeriod(root, 990);
      const res = await vesting.claim(root, 0, wallet0, 100, proof0);
      expect(res.receipt.status).to.be.true;
    });

    it("updates lastEndingCohort, but only if needed", async function () {
      expect(await vesting.lastEndingCohort()).to.eq(root);
      await vesting.addCohort(randomRoot0, 0, distributionDuration / 2, randomVestingPeriod, randomCliff);
      expect(await vesting.lastEndingCohort()).to.eq(root);
      await vesting.prolongDistributionPeriod(randomRoot0, distributionDuration / 3);
      expect(await vesting.lastEndingCohort()).to.eq(root);
      await vesting.prolongDistributionPeriod(randomRoot0, distributionDuration);
      expect(await vesting.lastEndingCohort()).to.eq(randomRoot0);
    });

    it("emits DistributionProlonged event", async function () {
      const addition = new BN(99);
      const result = await vesting.prolongDistributionPeriod(root, addition);
      const cohort = await vesting.getCohort(root);
      await expectEvent(result, "DistributionProlonged", {
        cohortId: root,
        newDistributionEnd: cohort.distributionEnd
      });
    });
  });

  context("#withdraw", async function () {
    let vesting;

    beforeEach("deploy contract", async function () {
      vesting = await Vesting.new(token.address, wallet0);
      await vesting.addCohort(randomRoot0, 0, distributionDuration, randomVestingPeriod, randomCliff);
    });

    it("fails if not called by the owner", async function () {
      await expectRevert(vesting.withdraw(wallet0, { from: wallet1 }), "Ownable: caller is not the owner");
    });

    it("fails if distribution period has not ended yet", async function () {
      // error DistributionOngoing(uint256 current, uint256 end);
      await expectRevert.unspecified(vesting.withdraw(wallet0));
    });

    it("fails if there's nothing to withdraw", async function () {
      await time.increase(distributionDuration + 1);
      const balance = await token.balanceOf(vesting.address);
      expect(balance).to.bignumber.eq("0");
      // error AlreadyWithdrawn();
      await expectRevert.unspecified(vesting.withdraw(wallet0));
    });

    it("transfers tokens to the recipient", async function () {
      await setBalance(token, vesting.address, new BN(101));
      await time.increase(distributionDuration + 1);
      const oldBalance = await token.balanceOf(vesting.address);
      await vesting.withdraw(wallet0);
      const newBalance = await token.balanceOf(vesting.address);
      expect(oldBalance).to.bignumber.eq("101");
      expect(newBalance).to.bignumber.eq("0");
    });

    it("emits Withdrawn event", async function () {
      await setBalance(token, vesting.address, new BN(101));
      await time.increase(distributionDuration + 1);
      const result0 = await vesting.withdraw(wallet0);
      await expectEvent(result0, "Withdrawn", { account: wallet0, amount: "101" });
    });
  });
});
