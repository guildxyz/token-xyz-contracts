const { BigNumber, constants } = require("ethers");
const { BN, time, expectRevert, expectEvent } = require("@openzeppelin/test-helpers");
const expect = require("chai").expect;
const { tsImport } = require("ts-import");

const Distributor = artifacts.require("MerkleDistributor");
const ERC20MintableBurnable = artifacts.require("ERC20MintableBurnable");

// ts imports
async function importTs() {
  const filePath1 = "./scripts/merkleTree/balance-tree.ts";
  BalanceTree = await tsImport.compile(filePath1);
  const filePath2 = "./scripts/merkleTree/parse-balance-map.ts";
  parseBalanceMap = await tsImport.compile(filePath2);
}

let BalanceTree;
let parseBalanceMap;

const gasEps = 1000;

async function setBalance(token, to, amount) {
  const old = await token.balanceOf(to);
  if (old.lt(amount)) await token.mint(to, amount.sub(old));
  else if (old.gt(amount)) await token.burn(to, old.sub(amount));
}

contract("MerkleDistributor", function (accounts) {
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
      const distributor = await Distributor.new(token.address, constants.HashZero, distributionDuration, wallet0);
      expect(await distributor.token()).to.eq(token.address);
    });
  });

  context("#merkleRoot", function () {
    it("returns the zero merkle root", async function () {
      const distributor = await Distributor.new(token.address, constants.HashZero, distributionDuration, wallet0);
      expect(await distributor.merkleRoot()).to.eq(constants.HashZero);
    });
  });

  context("#distributionEnd", function () {
    it("returns the distribution end timestamp", async function () {
      const distributor = await Distributor.new(token.address, constants.HashZero, distributionDuration, wallet0);
      const timestamp = await time.latest();
      expect(await distributor.distributionEnd()).to.bignumber.eq(timestamp.add(new BN(distributionDuration)));
    });
  });

  context("#claim", function () {
    it("fails if distribution ended", async function () {
      const distributor = await Distributor.new(token.address, constants.HashZero, distributionDuration, wallet0);
      await time.increase(distributionDuration + 1);
      // error DistributionEnded(uint256 current, uint256 end);
      await expectRevert.unspecified(distributor.claim(0, wallet0, 10, []));
    });

    it("fails for empty proof", async function () {
      const distributor = await Distributor.new(token.address, constants.HashZero, distributionDuration, wallet0);
      // error InvalidProof();
      await expectRevert.unspecified(distributor.claim(0, wallet0, 10, []));
    });

    it("fails for invalid index", async function () {
      const distributor = await Distributor.new(token.address, constants.HashZero, distributionDuration, wallet0);
      // error InvalidProof();
      await expectRevert.unspecified(distributor.claim(0, wallet0, 10, []));
    });

    context("two account tree", function () {
      let distributor;
      let tree;

      before("create tree", function () {
        tree = new BalanceTree.default([
          { account: wallet0, amount: BigNumber.from(100) },
          { account: wallet1, amount: BigNumber.from(101) }
        ]);
      });

      beforeEach("deploy", async function () {
        distributor = await Distributor.new(token.address, tree.getHexRoot(), distributionDuration, wallet0);
        await setBalance(token, distributor.address, new BN(201));
      });

      it("successful claim", async function () {
        const proof0 = tree.getProof(0, wallet0, BigNumber.from(100));
        const result0 = await distributor.claim(0, wallet0, 100, proof0);
        await expectEvent(result0, "Claimed", { index: "0", account: wallet0, amount: "100" });
        const proof1 = tree.getProof(1, wallet1, BigNumber.from(101));
        const result1 = await distributor.claim(1, wallet1, 101, proof1);
        await expectEvent(result1, "Claimed", { index: "1", account: wallet1, amount: "101" });
      });

      it("transfers the token", async function () {
        const proof0 = tree.getProof(0, wallet0, BigNumber.from(100));
        expect(await token.balanceOf(wallet0)).to.bignumber.eq("0");
        await distributor.claim(0, wallet0, 100, proof0);
        expect(await token.balanceOf(wallet0)).to.bignumber.eq("100");
      });

      it("must have enough to transfer", async function () {
        const proof0 = tree.getProof(0, wallet0, BigNumber.from(100));
        await setBalance(token, distributor.address, new BN(99));
        await expectRevert(distributor.claim(0, wallet0, 100, proof0), "ERC20: transfer amount exceeds balance");
      });

      it("sets #isClaimed", async function () {
        const proof0 = tree.getProof(0, wallet0, BigNumber.from(100));
        expect(await distributor.isClaimed(0)).to.eq(false);
        expect(await distributor.isClaimed(1)).to.eq(false);
        await distributor.claim(0, wallet0, 100, proof0);
        expect(await distributor.isClaimed(0)).to.eq(true);
        expect(await distributor.isClaimed(1)).to.eq(false);
      });

      it("cannot allow two claims", async function () {
        const proof0 = tree.getProof(0, wallet0, BigNumber.from(100));
        await distributor.claim(0, wallet0, 100, proof0);
        // error DropClaimed();
        await expectRevert.unspecified(distributor.claim(0, wallet0, 100, proof0));
      });

      it("cannot claim more than once: 0 and then 1", async function () {
        await distributor.claim(0, wallet0, 100, tree.getProof(0, wallet0, BigNumber.from(100)));
        await distributor.claim(1, wallet1, 101, tree.getProof(1, wallet1, BigNumber.from(101)));

        // error DropClaimed();
        await expectRevert.unspecified(
          distributor.claim(0, wallet0, 100, tree.getProof(0, wallet0, BigNumber.from(100)))
        );
      });

      it("cannot claim more than once: 1 and then 0", async function () {
        await distributor.claim(1, wallet1, 101, tree.getProof(1, wallet1, BigNumber.from(101)));
        await distributor.claim(0, wallet0, 100, tree.getProof(0, wallet0, BigNumber.from(100)));

        // error DropClaimed();
        await expectRevert.unspecified(
          distributor.claim(1, wallet1, 101, tree.getProof(1, wallet1, BigNumber.from(101)))
        );
      });

      it("cannot claim for address other than proof", async function () {
        const proof0 = tree.getProof(0, wallet0, BigNumber.from(100));
        // error InvalidProof();
        await expectRevert.unspecified(distributor.claim(1, wallet1, 101, proof0));
      });

      it("cannot claim more with one proof", async function () {
        const proof0 = tree.getProof(0, wallet0, BigNumber.from(100));
        // error InvalidProof();
        await expectRevert.unspecified(distributor.claim(0, wallet0, 101, proof0));
      });

      it("gas", async function () {
        const proof = tree.getProof(0, wallet0, BigNumber.from(100));
        const tx = await distributor.claim(0, wallet0, 100, proof);
        expect(tx.receipt.gasUsed).to.closeTo(81139, gasEps);
      });
    });

    context("larger tree", function () {
      let distributor;
      let tree;

      before("create tree", function () {
        tree = new BalanceTree.default(
          accounts.map((wallet, ix) => {
            return { account: wallet, amount: BigNumber.from(ix + 1) };
          })
        );
      });

      beforeEach("deploy", async function () {
        distributor = await Distributor.new(token.address, tree.getHexRoot(), distributionDuration, wallet0);
        await setBalance(token, distributor.address, new BN(201));
      });

      it("claim index 4", async function () {
        const proof = tree.getProof(4, accounts[4], BigNumber.from(5));
        const result = await distributor.claim(4, accounts[4], 5, proof);
        await expectEvent(result, "Claimed", { index: "4", account: accounts[4], amount: "5" });
      });

      it("claim index 9", async function () {
        const proof = tree.getProof(9, accounts[9], BigNumber.from(10));
        const result = await distributor.claim(9, accounts[9], 10, proof);
        await expectEvent(result, "Claimed", { index: "9", account: accounts[9], amount: "10" });
      });

      it("gas", async function () {
        const proof = tree.getProof(9, accounts[9], BigNumber.from(10));
        const tx = await distributor.claim(9, accounts[9], 10, proof);
        expect(tx.receipt.gasUsed).to.closeTo(83554, gasEps);
      });

      it("gas second down about 15k", async function () {
        await distributor.claim(0, wallet0, 1, tree.getProof(0, wallet0, BigNumber.from(1)));
        const tx = await distributor.claim(1, wallet1, 2, tree.getProof(1, wallet1, BigNumber.from(2)));
        expect(tx.receipt.gasUsed).to.closeTo(65830, gasEps);
      });
    });

    context("realistic size tree", function () {
      let distributor;
      let tree;
      const NUM_LEAVES = 100_000;
      const NUM_SAMPLES = 25;
      const elements = [];

      before("create tree", function () {
        for (let i = 0; i < NUM_LEAVES; i++) {
          const node = { account: wallet0, amount: BigNumber.from(100) };
          elements.push(node);
        }
        tree = new BalanceTree.default(elements);
      });

      it("proof verification works", function () {
        const root = Buffer.from(tree.getHexRoot().slice(2), "hex");
        for (let i = 0; i < NUM_LEAVES; i += NUM_LEAVES / NUM_SAMPLES) {
          const proof = tree.getProof(i, wallet0, BigNumber.from(100)).map((el) => Buffer.from(el.slice(2), "hex"));
          const validProof = BalanceTree.default.verifyProof(i, wallet0, BigNumber.from(100), proof, root);
          expect(validProof).to.be.true;
        }
      });

      beforeEach("deploy", async function () {
        distributor = await Distributor.new(token.address, tree.getHexRoot(), distributionDuration, wallet0);
        await setBalance(token, distributor.address, new BN(100000000));
      });

      it("gas", async function () {
        const proof = tree.getProof(50000, wallet0, BigNumber.from(100));
        const tx = await distributor.claim(50000, wallet0, 100, proof);
        expect(tx.receipt.gasUsed).to.closeTo(93992, gasEps);
      });

      it("gas deeper node", async function () {
        const proof = tree.getProof(90000, wallet0, BigNumber.from(100));
        const tx = await distributor.claim(90000, wallet0, 100, proof);
        expect(tx.receipt.gasUsed).to.closeTo(94090, gasEps);
      });

      it("gas average random distribution", async function () {
        let total = BigNumber.from(0);
        let count = 0;
        for (let i = 0; i < NUM_LEAVES; i += NUM_LEAVES / NUM_SAMPLES) {
          const proof = tree.getProof(i, wallet0, BigNumber.from(100));
          const tx = await distributor.claim(i, wallet0, 100, proof);
          total = total.add(tx.receipt.gasUsed);
          count++;
        }
        const average = total.div(count);
        expect(average.toNumber()).to.closeTo(77617, gasEps);
      });

      // this is what we gas golfed by packing the bitmap
      it("gas average first 25", async function () {
        let total = BigNumber.from(0);
        let count = 0;
        for (let i = 0; i < 25; i++) {
          const proof = tree.getProof(i, wallet0, BigNumber.from(100));
          const tx = await distributor.claim(i, wallet0, 100, proof);
          total = total.add(tx.receipt.gasUsed);
          count++;
        }
        const average = total.div(count);
        expect(average.toNumber()).to.closeTo(61186, gasEps);
      });

      it("no double claims in random distribution", async function () {
        for (let i = 0; i < 25; i += Math.floor(Math.random() * (NUM_LEAVES / NUM_SAMPLES))) {
          const proof = tree.getProof(i, wallet0, BigNumber.from(100));
          await distributor.claim(i, wallet0, 100, proof);
          // error InvalidProof();
          await expectRevert.unspecified(distributor.claim(i, wallet0, 100, proof));
        }
      });
    });
  });

  context("#withdraw", async function () {
    it("fails if distribution period has not ended yet", async function () {
      const distributor = await Distributor.new(token.address, constants.HashZero, distributionDuration, wallet0);
      // error DistributionOngoing(uint256 current, uint256 end);
      await expectRevert.unspecified(distributor.withdraw(wallet0));
    });

    it("fails if there's nothing to withdraw", async function () {
      const distributor = await Distributor.new(token.address, constants.HashZero, distributionDuration, wallet0);
      await time.increase(distributionDuration + 1);
      const balance = await token.balanceOf(distributor.address);
      expect(balance).to.bignumber.eq("0");
      // error AlreadyWithdrawn();
      await expectRevert.unspecified(distributor.withdraw(wallet0));
    });

    it("transfers tokens to the recipient", async function () {
      const distributor = await Distributor.new(token.address, constants.HashZero, distributionDuration, wallet0);
      await setBalance(token, distributor.address, new BN("101"));
      await time.increase(distributionDuration + 1);
      const oldBalance = await token.balanceOf(distributor.address);
      await distributor.withdraw(wallet0);
      const newBalance = await token.balanceOf(distributor.address);
      expect(oldBalance).to.bignumber.eq("101");
      expect(newBalance).to.bignumber.eq("0");
    });

    it("emits Withdrawn event", async function () {
      const distributor = await Distributor.new(token.address, constants.HashZero, distributionDuration, wallet0);
      await setBalance(token, distributor.address, new BN("101"));
      await time.increase(distributionDuration + 1);
      const result = await distributor.withdraw(wallet0);
      await expectEvent(result, "Withdrawn", { account: wallet0, amount: "101" });
    });
  });

  xcontext("parseBalanceMap", function () {
    let distributor;
    let claims;

    beforeEach("deploy", async function () {
      const {
        claims: innerClaims,
        merkleRoot,
        tokenTotal
      } = parseBalanceMap.parseBalanceMap({
        [wallet0]: 200,
        [wallet1]: 300,
        [accounts[2]]: 250
      });
      console.log(innerClaims);
      expect(tokenTotal).to.eq("0x02ee"); // 750
      claims = innerClaims;
      distributor = await Distributor.new(token.address, merkleRoot, distributionDuration, wallet0);
      await setBalance(token, distributor.address, new BN(tokenTotal));
    });

    it("check the proofs are as expected", function () {
      expect(claims).to.deep.eq({
        [wallet0]: {
          index: 0,
          amount: "0xc8",
          proof: ["0x2a411ed78501edb696adca9e41e78d8256b61cfac45612fa0434d7cf87d916c6"]
        },
        [wallet1]: {
          index: 1,
          amount: "0x012c",
          proof: [
            "0xbfeb956a3b705056020a3b64c540bff700c0f6c96c55c0a5fcab57124cb36f7b",
            "0xd31de46890d4a77baeebddbd77bf73b5c626397b73ee8c69b51efe4c9a5a72fa"
          ]
        },
        [accounts[2]]: {
          index: 2,
          amount: "0xfa",
          proof: [
            "0xceaacce7533111e902cc548e961d77b23a4d8cd073c6b68ccf55c62bd47fc36b",
            "0xd31de46890d4a77baeebddbd77bf73b5c626397b73ee8c69b51efe4c9a5a72fa"
          ]
        }
      });
    });

    it("all claims work exactly once", async function () {
      for (let account in claims) {
        const claim = claims[account];
        const result = await distributor.claim(claim.index, account, claim.amount, claim.proof);
        await expectEvent(result, "Claimed", {
          index: claim.index.toString(),
          account: account,
          amount: BigNumber.from(claim.amount).toString()
        });
        // error DropClaimed();
        await expectRevert.unspecified(distributor.claim(claim.index, account, claim.amount, claim.proof));
      }
      expect(await token.balanceOf(distributor.address)).to.eq(0);
    });
  });
});
