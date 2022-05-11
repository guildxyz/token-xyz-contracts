const { BigNumber, constants } = require("ethers");
const { BN, expectEvent, expectRevert, time } = require("@openzeppelin/test-helpers");
const expect = require("chai").expect;
const { tsImport } = require("ts-import");

const ERC721MerkleDrop = artifacts.require("ERC721MerkleDrop");

// ts imports
async function importTs() {
  const filePath1 = "./scripts/merkleTree/balance-tree.ts";
  BalanceTree = await tsImport.compile(filePath1);
  const filePath2 = "./scripts/merkleTree/parse-balance-map.ts";
  parseBalanceMap = await tsImport.compile(filePath2);
}

let BalanceTree;
let parseBalanceMap;
const randomRoot = "0xf7f77ea15719ea30bd2a584962ab273b1116f0e70fe80bbb0b30557d0addb7f3";
const tokenName = "OwoNFT";
const tokenSymbol = "OFT";
const tokenCid = "QmPaZD7i8TpLEeGjHtGoXe4mPKbRNNt8YTHH5nrKoqz9wJ";
const tokenMaxSupply = "12";
const distributionDuration = 86400;

contract("ERC721MerkleDrop", function (accounts) {
  const [wallet0, wallet1] = accounts;

  before("import ts libs", async function () {
    await importTs();
  });

  context("constructor and initial setup", function () {
    it("fails if called with invalid parameters", async function () {
      // error InvalidParameters();
      await expectRevert(
        ERC721MerkleDrop.new(
          tokenName,
          tokenSymbol,
          tokenCid,
          tokenMaxSupply,
          randomRoot,
          distributionDuration,
          constants.AddressZero
        ),
        "Custom error (could not decode)"
      );
      await expectRevert(
        ERC721MerkleDrop.new(
          tokenName,
          tokenSymbol,
          tokenCid,
          tokenMaxSupply,
          constants.HashZero,
          distributionDuration,
          constants.AddressZero
        ),
        "Custom error (could not decode)"
      );

      // error MaxSupplyZero();
      await expectRevert(
        ERC721MerkleDrop.new(
          tokenName,
          tokenSymbol,
          tokenCid,
          0,
          randomRoot,
          distributionDuration,
          constants.AddressZero
        ),
        "Custom error (could not decode)"
      );
    });

    it("should have correct metadata & owner", async function () {
      const token = await ERC721MerkleDrop.new(
        tokenName,
        tokenSymbol,
        tokenCid,
        tokenMaxSupply,
        randomRoot,
        distributionDuration,
        wallet0
      );
      const name = await token.name();
      const symbol = await token.symbol();
      const maxSupply = await token.maxSupply();
      const owner = await token.owner();
      const merkleRoot = await token.merkleRoot();
      expect(name).to.eq(tokenName);
      expect(symbol).to.eq(tokenSymbol);
      expect(maxSupply).to.bignumber.eq(tokenMaxSupply);
      expect(owner).to.eq(wallet0);
      expect(merkleRoot).to.eq(randomRoot);
    });

    it("returns the distribution end timestamp", async function () {
      const token = await ERC721MerkleDrop.new(
        tokenName,
        tokenSymbol,
        tokenCid,
        tokenMaxSupply,
        randomRoot,
        distributionDuration,
        wallet0
      );
      const timestamp = await time.latest();
      expect(await token.distributionEnd()).to.bignumber.eq(timestamp.add(new BN(distributionDuration)));
    });

    it("should have zero tokens initially", async function () {
      const token = await ERC721MerkleDrop.new(
        tokenName,
        tokenSymbol,
        tokenCid,
        tokenMaxSupply,
        randomRoot,
        distributionDuration,
        wallet0
      );
      const totalSupply = await token.totalSupply();
      expect(totalSupply).to.bignumber.eq("0");
    });
  });

  context("tokenURI", function () {
    beforeEach("create a token", async function () {
      token = await ERC721MerkleDrop.new(
        tokenName,
        tokenSymbol,
        tokenCid,
        tokenMaxSupply,
        randomRoot,
        distributionDuration,
        wallet0
      );
    });

    it("should revert when trying to get the tokenURI for a non-existent token", async function () {
      // error NonExistentToken(uint256 tokenId);
      expectRevert.unspecified(token.tokenURI(84));
    });

    it("should return the correct tokenURI", async function () {
      await time.increase(distributionDuration + 1);
      await token.safeMint(wallet1, 0);
      const regex = new RegExp(`ipfs:\/\/${tokenCid}\/0.json`);
      expect(regex.test(await token.tokenURI(0))).to.be.true;
    });
  });

  context("claim", function () {
    it("fails if distribution ended", async function () {
      const token = await ERC721MerkleDrop.new(
        tokenName,
        tokenSymbol,
        tokenCid,
        tokenMaxSupply,
        randomRoot,
        distributionDuration,
        wallet0
      );
      await time.increase(distributionDuration + 1);
      // error DistributionEnded(uint256 current, uint256 end);
      await expectRevert.unspecified(token.claim(0, wallet0, 10, []));
    });

    it("fails for empty proof", async function () {
      const token = await ERC721MerkleDrop.new(
        tokenName,
        tokenSymbol,
        tokenCid,
        tokenMaxSupply,
        randomRoot,
        distributionDuration,
        wallet0
      );
      // error InvalidProof();
      await expectRevert.unspecified(token.claim(0, wallet0, 10, []));
    });

    it("fails for invalid index", async function () {
      const token = await ERC721MerkleDrop.new(
        tokenName,
        tokenSymbol,
        tokenCid,
        tokenMaxSupply,
        randomRoot,
        distributionDuration,
        wallet0
      );
      await expectRevert.unspecified(token.claim(1000, wallet0, 10, []));
    });

    context("two account tree", function () {
      let token;
      let tree;

      before("create tree", function () {
        tree = new BalanceTree.default([
          { account: wallet0, amount: BigNumber.from(10) },
          { account: wallet1, amount: BigNumber.from(11) }
        ]);
      });

      beforeEach("deploy", async function () {
        token = await ERC721MerkleDrop.new(
          tokenName,
          tokenSymbol,
          tokenCid,
          tokenMaxSupply,
          tree.getHexRoot(),
          distributionDuration,
          wallet0
        );
      });

      it("successful claim", async function () {
        const proof0 = tree.getProof(0, wallet0, BigNumber.from(10));
        const result0 = await token.claim(0, wallet0, 10, proof0);
        await expectEvent(result0, "Transfer", { from: constants.AddressZero, to: wallet0, tokenId: "10" });
        const proof1 = tree.getProof(1, wallet1, BigNumber.from(11));
        const result1 = await token.claim(1, wallet1, 11, proof1);
        await expectEvent(result1, "Transfer", { from: constants.AddressZero, to: wallet1, tokenId: "11" });
      });

      it("transfers the token", async function () {
        const proof0 = tree.getProof(0, wallet0, BigNumber.from(10));
        const tokenId = 10;
        expect(await token.balanceOf(wallet0)).to.bignumber.eq("0");
        await expectRevert(token.ownerOf(tokenId), "ERC721: owner query for nonexistent token");
        await token.claim(0, wallet0, 10, proof0);
        expect(await token.balanceOf(wallet0)).to.bignumber.eq("1");
        expect(await token.ownerOf(tokenId)).to.eq(wallet0);
      });

      it("cannot allow two claims", async function () {
        const proof0 = tree.getProof(0, wallet0, BigNumber.from(10));
        await token.claim(0, wallet0, 10, proof0);
        await expectRevert(token.claim(0, wallet0, 10, proof0), "ERC721: token already minted");
      });

      it("cannot claim more than once: 0 and then 1", async function () {
        await token.claim(0, wallet0, 10, tree.getProof(0, wallet0, BigNumber.from(10)));
        await token.claim(1, wallet1, 11, tree.getProof(1, wallet1, BigNumber.from(11)));
        await expectRevert(
          token.claim(0, wallet0, 10, tree.getProof(0, wallet0, BigNumber.from(10))),
          "ERC721: token already minted"
        );
      });

      it("cannot claim more than once: 1 and then 0", async function () {
        await token.claim(1, wallet1, 11, tree.getProof(1, wallet1, BigNumber.from(11)));
        await token.claim(0, wallet0, 10, tree.getProof(0, wallet0, BigNumber.from(10)));
        await expectRevert(
          token.claim(1, wallet1, 11, tree.getProof(1, wallet1, BigNumber.from(11))),
          "ERC721: token already minted"
        );
      });

      it("cannot claim for address other than proof", async function () {
        const proof0 = tree.getProof(0, wallet0, BigNumber.from(10));
        // error InvalidProof();
        await expectRevert.unspecified(token.claim(1, wallet1, 11, proof0));
      });

      it("cannot claim more with one proof", async function () {
        const proof0 = tree.getProof(0, wallet0, BigNumber.from(10));
        // error InvalidProof();
        await expectRevert.unspecified(token.claim(0, wallet0, 11, proof0));
      });
    });

    context("larger tree", function () {
      let token;
      let tree;

      before("create tree", function () {
        tree = new BalanceTree.default(
          accounts.map((wallet, ix) => {
            return { account: wallet, amount: BigNumber.from(ix + 1) };
          })
        );
      });

      beforeEach("deploy", async function () {
        token = await ERC721MerkleDrop.new(
          tokenName,
          tokenSymbol,
          tokenCid,
          tokenMaxSupply,
          tree.getHexRoot(),
          distributionDuration,
          wallet0
        );
      });

      it("claim index 4", async function () {
        const proof = tree.getProof(4, accounts[4], BigNumber.from(5));
        const result = await token.claim(4, accounts[4], 5, proof);
        await expectEvent(result, "Transfer", { from: constants.AddressZero, to: accounts[4], tokenId: "5" });
      });

      it("claim index 9", async function () {
        const proof = tree.getProof(9, accounts[9], BigNumber.from(10));
        const result = await token.claim(9, accounts[9], 10, proof);
        await expectEvent(result, "Transfer", { from: constants.AddressZero, to: accounts[9], tokenId: "10" });
      });
    });

    context("realistic size tree", function () {
      let tree;
      const NUM_LEAVES = 100_000;
      const NUM_SAMPLES = 25;
      const elements = [];

      before("create tree", function () {
        for (let i = 0; i < NUM_LEAVES; i++) {
          const node = { account: wallet0, amount: BigNumber.from(1) };
          elements.push(node);
        }
        tree = new BalanceTree.default(elements);
      });

      it("proof verification works", function () {
        const root = Buffer.from(tree.getHexRoot().slice(2), "hex");
        for (let i = 0; i < NUM_LEAVES; i += NUM_LEAVES / NUM_SAMPLES) {
          const proof = tree.getProof(i, wallet0, BigNumber.from(1)).map((el) => Buffer.from(el.slice(2), "hex"));
          const validProof = BalanceTree.default.verifyProof(i, wallet0, BigNumber.from(1), proof, root);
          expect(validProof).to.be.true;
        }
      });

      it("no double claims in random distribution", async function () {
        const token = await ERC721MerkleDrop.new(
          tokenName,
          tokenSymbol,
          tokenCid,
          tokenMaxSupply,
          tree.getHexRoot(),
          distributionDuration,
          wallet0
        );
        for (let i = 0; i < 25; i += Math.floor(Math.random() * (NUM_LEAVES / NUM_SAMPLES))) {
          const proof = tree.getProof(i, wallet0, BigNumber.from(1));
          await token.claim(i, wallet0, 1, proof);
          await expectRevert(token.claim(i, wallet0, 1, proof), "ERC721: token already minted");
        }
      });
    });
  });

  context("parseBalanceMap", function () {
    let token;
    let claims;

    beforeEach("deploy", async function () {
      const {
        claims: innerClaims,
        merkleRoot,
        tokenTotal
      } = parseBalanceMap.parseBalanceMap({
        [wallet0]: 2,
        [wallet1]: 3,
        [accounts[2]]: 5
      });
      expect(tokenTotal).to.eq("0x0a"); // 10
      claims = innerClaims;
      token = await ERC721MerkleDrop.new(
        tokenName,
        tokenSymbol,
        tokenCid,
        tokenMaxSupply,
        merkleRoot,
        distributionDuration,
        wallet0
      );
    });

    it("all claims work exactly once", async function () {
      for (let account in claims) {
        const claim = claims[account];
        const result = await token.claim(claim.index, account, claim.amount, claim.proof);
        await expectEvent(result, "Transfer", {
          from: constants.AddressZero,
          to: account,
          tokenId: Number(claim.amount).toString()
        });
        await expectRevert(
          token.claim(claim.index, account, claim.amount, claim.proof),
          "ERC721: token already minted"
        );
      }
    });
  });

  context("minting", function () {
    let token;

    beforeEach("deploy", async function () {
      token = await ERC721MerkleDrop.new(
        tokenName,
        tokenSymbol,
        tokenCid,
        tokenMaxSupply,
        randomRoot,
        distributionDuration,
        wallet0
      );
    });

    it("fails before distributionEnd", async function () {
      // error DistributionOngoing(uint256 current, uint256 end);
      await expectRevert.unspecified(token.safeMint(wallet0, 0));
    });

    it("fails if not called by the owner", async function () {
      await expectRevert(token.safeMint(wallet0, 0, { from: wallet1 }), "Ownable: caller is not the owner");
    });

    it("should not be possible to mint a token with the same ID twice", async function () {
      await time.increase(distributionDuration + 1);
      await token.safeMint(wallet0, 0);
      await expectRevert(token.safeMint(wallet0, 0), "ERC721: token already minted");
    });

    it("fails to mint above maxSupply", async function () {
      await time.increase(distributionDuration + 1);
      // error TokenIdOutOfBounds();
      await expectRevert.unspecified(token.safeMint(wallet0, tokenMaxSupply + 1));
    });

    it("minting increases totalSupply", async function () {
      await time.increase(distributionDuration + 1);
      const totalSupply = await token.totalSupply();
      await token.safeMint(wallet0, 0);
      expect(await token.totalSupply()).to.bignumber.eq(totalSupply.add(new BN(1)));
    });

    it("should really be mintable", async function () {
      await time.increase(distributionDuration + 1);
      const oldBalance = await token.balanceOf(wallet1);
      await token.safeMint(wallet1, 0);
      const newBalance = await token.balanceOf(wallet1);
      expect(newBalance).to.bignumber.eq(oldBalance.add(new BN(1)));
    });
  });
});
