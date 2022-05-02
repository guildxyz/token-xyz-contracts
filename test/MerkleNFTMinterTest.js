const { BigNumber, constants } = require("ethers");
const { BN, time, expectRevert, expectEvent } = require("@openzeppelin/test-helpers");
const expect = require("chai").expect;
const { tsImport } = require("ts-import");

const MinterSpecific = artifacts.require("MerkleNFTMinter");
const MinterAuto = artifacts.require("MerkleNFTMinterAutoId");
const ERC721 = artifacts.require("ERC721Mintable");
const ERC721AutoIdBatchMint = artifacts.require("ERC721AutoIdBatchMint");

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

const nftMetadata0 = {
  name: "NFTXYZ",
  symbol: "XYZ",
  ipfsHash: "QmPaZD7i8TpLEeGjHtGoXe4mPKbRNNt8YTHH5nrKoqz9wJ",
  maxSupply: "420"
};

const runOptions = [
  {
    contract: "MerkleNFTMinterAutoId",
    Minter: MinterAuto,
    ERC721: ERC721AutoIdBatchMint
  },
  {
    contract: "MerkleNFTMinter",
    Minter: MinterSpecific,
    ERC721: ERC721
  }
];

contract("MerkleNFTMinter", function (accounts) {
  const [wallet0, wallet1] = accounts;
  const distributionDuration = 86400;

  before("import ts libs", async function () {
    await importTs();
  });

  for (const runOption of runOptions) {
    context(runOption.contract, async function () {
      context("#constructor", function () {
        it("fails if called with invalid parameters", async function () {
          // error InvalidParameters();
          await expectRevert(
            runOption.Minter.new(randomRoot, distributionDuration, nftMetadata0, constants.AddressZero),
            "Custom error (could not decode)"
          );
          await expectRevert(
            runOption.Minter.new(constants.HashZero, distributionDuration, nftMetadata0, wallet0),
            "Custom error (could not decode)"
          );
        });

        it("returns the token address", async function () {
          const minter = await runOption.Minter.new(randomRoot, distributionDuration, nftMetadata0, wallet0);
          expect(await minter.token()).to.not.eq("0x0000000000000000000000000000000000000000");
        });

        it("returns the Merkle root", async function () {
          const minter = await runOption.Minter.new(randomRoot, distributionDuration, nftMetadata0, wallet0);
          expect(await minter.merkleRoot()).to.eq(randomRoot);
        });

        it("returns the distribution end timestamp", async function () {
          const minter = await runOption.Minter.new(randomRoot, distributionDuration, nftMetadata0, wallet0);
          const timestamp = await time.latest();
          expect(await minter.distributionEnd()).to.bignumber.eq(timestamp.add(new BN(distributionDuration)));
        });
      });

      context("#claim", function () {
        it("fails if distribution ended", async function () {
          const minter = await runOption.Minter.new(randomRoot, distributionDuration, nftMetadata0, wallet0);
          await time.increase(distributionDuration + 1);
          // error DistributionEnded(uint256 current, uint256 end);
          await expectRevert.unspecified(minter.claim(0, wallet0, 10, []));
        });

        it("fails for empty proof", async function () {
          const minter = await runOption.Minter.new(randomRoot, distributionDuration, nftMetadata0, wallet0);
          // error InvalidProof();
          await expectRevert.unspecified(minter.claim(0, wallet0, 10, []));
        });

        it("fails for invalid index", async function () {
          const minter = await runOption.Minter.new(randomRoot, distributionDuration, nftMetadata0, wallet0);
          // error InvalidProof();
          await expectRevert.unspecified(minter.claim(0, wallet0, 10, []));
        });

        context("two account tree", function () {
          let minter;
          let token;
          let tree;

          before("create tree", function () {
            tree = new BalanceTree.default([
              { account: wallet0, amount: BigNumber.from(10) },
              { account: wallet1, amount: BigNumber.from(11) }
            ]);
          });

          beforeEach("deploy", async function () {
            minter = await runOption.Minter.new(tree.getHexRoot(), distributionDuration, nftMetadata0, wallet0);
            const tokenAddress = await minter.token();
            token = await runOption.ERC721.at(tokenAddress);
          });

          it("successful claim", async function () {
            const proof0 = tree.getProof(0, wallet0, BigNumber.from(10));
            const result0 = await minter.claim(0, wallet0, 10, proof0);
            await expectEvent(result0, "Claimed", { index: "0", account: wallet0 });
            const proof1 = tree.getProof(1, wallet1, BigNumber.from(11));
            const result1 = await minter.claim(1, wallet1, 11, proof1);
            await expectEvent(result1, "Claimed", { index: "1", account: wallet1 });
          });

          it("transfers the token(s)", async function () {
            const proof0 = tree.getProof(0, wallet0, BigNumber.from(10));
            const tokenId = runOption.contract === "MerkleNFTMinterAutoId" ? await token.totalSupply() : 10;
            expect(await token.balanceOf(wallet0)).to.bignumber.eq("0");
            await expectRevert(token.ownerOf(tokenId), "ERC721: owner query for nonexistent token");
            await minter.claim(0, wallet0, 10, proof0);
            if (runOption.contract === "MerkleNFTMinterAutoId") {
              expect(await token.balanceOf(wallet0)).to.bignumber.eq("10");
              for (let i = 0; i < 10; i++) {
                expect(await token.ownerOf(i)).to.eq(wallet0);
              }
            } else {
              expect(await token.balanceOf(wallet0)).to.bignumber.eq("1");
              expect(await token.ownerOf(tokenId)).to.eq(wallet0);
            }
          });

          it("sets #isClaimed", async function () {
            const proof0 = tree.getProof(0, wallet0, BigNumber.from(10));
            expect(await minter.isClaimed(0)).to.eq(false);
            expect(await minter.isClaimed(1)).to.eq(false);
            await minter.claim(0, wallet0, 10, proof0);
            expect(await minter.isClaimed(0)).to.eq(true);
            expect(await minter.isClaimed(1)).to.eq(false);
          });

          it("cannot allow two claims", async function () {
            const proof0 = tree.getProof(0, wallet0, BigNumber.from(10));
            await minter.claim(0, wallet0, 10, proof0);
            // error DropClaimed();
            await expectRevert.unspecified(minter.claim(0, wallet0, 10, proof0));
          });

          it("cannot claim more than once: 0 and then 1", async function () {
            await minter.claim(0, wallet0, 10, tree.getProof(0, wallet0, BigNumber.from(10)));
            await minter.claim(1, wallet1, 11, tree.getProof(1, wallet1, BigNumber.from(11)));
            // error DropClaimed();
            await expectRevert.unspecified(minter.claim(0, wallet0, 10, tree.getProof(0, wallet0, BigNumber.from(10))));
          });

          it("cannot claim more than once: 1 and then 0", async function () {
            await minter.claim(1, wallet1, 11, tree.getProof(1, wallet1, BigNumber.from(11)));
            await minter.claim(0, wallet0, 10, tree.getProof(0, wallet0, BigNumber.from(10)));
            // error DropClaimed();
            await expectRevert.unspecified(minter.claim(1, wallet1, 11, tree.getProof(1, wallet1, BigNumber.from(11))));
          });

          it("cannot claim for address other than proof", async function () {
            const proof0 = tree.getProof(0, wallet0, BigNumber.from(10));
            // error InvalidProof();
            await expectRevert.unspecified(minter.claim(1, wallet1, 11, proof0));
          });

          it("cannot claim more with one proof", async function () {
            const proof0 = tree.getProof(0, wallet0, BigNumber.from(10));
            // error InvalidProof();
            await expectRevert.unspecified(minter.claim(0, wallet0, 11, proof0));
          });
        });

        context("larger tree", function () {
          let minter;
          let tree;

          before("create tree", function () {
            tree = new BalanceTree.default(
              accounts.map((wallet, ix) => {
                return { account: wallet, amount: BigNumber.from(ix + 1) };
              })
            );
          });

          beforeEach("deploy", async function () {
            minter = await runOption.Minter.new(tree.getHexRoot(), distributionDuration, nftMetadata0, wallet0);
          });

          it("claim index 4", async function () {
            const proof = tree.getProof(4, accounts[4], BigNumber.from(5));
            const result = await minter.claim(4, accounts[4], 5, proof);
            await expectEvent(result, "Claimed", { index: "4", account: accounts[4] });
          });

          it("claim index 9", async function () {
            const proof = tree.getProof(9, accounts[9], BigNumber.from(10));
            const result = await minter.claim(9, accounts[9], 10, proof);
            await expectEvent(result, "Claimed", { index: "9", account: accounts[9] });
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
            const minter = await runOption.Minter.new(tree.getHexRoot(), distributionDuration, nftMetadata0, wallet0);
            for (let i = 0; i < 25; i += Math.floor(Math.random() * (NUM_LEAVES / NUM_SAMPLES))) {
              const proof = tree.getProof(i, wallet0, BigNumber.from(1));
              await minter.claim(i, wallet0, 1, proof);
              // error DropClaimed();
              await expectRevert.unspecified(minter.claim(i, wallet0, 1, proof));
            }
          });
        });
      });

      context("#withdraw", async function () {
        let minter;
        let token;

        beforeEach("deploy contracts", async function () {
          minter = await runOption.Minter.new(randomRoot, distributionDuration, nftMetadata0, wallet0);
          const tokenAddress = await minter.token();
          token = await runOption.ERC721.at(tokenAddress);
        });

        it("fails if not called by the owner", async function () {
          await expectRevert(minter.withdraw(wallet0, { from: wallet1 }), "Ownable: caller is not the owner");
        });

        it("fails if distribution period has not ended yet", async function () {
          // error DistributionOngoing(uint256 current, uint256 end);
          await expectRevert.unspecified(minter.withdraw(wallet0));
        });

        it("transfers the ownership of the token", async function () {
          await time.increase(distributionDuration + 1);
          const oldOwner = await token.owner();
          await minter.withdraw(wallet0);
          const newOwner = await token.owner();
          expect(oldOwner).to.eq(minter.address);
          expect(newOwner).to.eq(wallet0);
        });

        it("emits Withdrawn event", async function () {
          await time.increase(distributionDuration + 1);
          const result = await minter.withdraw(wallet1);
          await expectEvent(result, "Withdrawn", { token: token.address, account: wallet1 });
        });
      });

      context("parseBalanceMap", function () {
        let minter;
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
          minter = await runOption.Minter.new(merkleRoot, distributionDuration, nftMetadata0, wallet0);
          const tokenAddress = await minter.token();
          token = await runOption.ERC721.at(tokenAddress);
        });

        it("all claims work exactly once", async function () {
          for (let account in claims) {
            const claim = claims[account];
            const result = await minter.claim(claim.index, account, claim.amount, claim.proof);
            await expectEvent(result, "Claimed", {
              index: claim.index.toString(),
              account: account
            });
            // error DropClaimed();
            await expectRevert.unspecified(minter.claim(claim.index, account, claim.amount, claim.proof));
          }
          expect(await token.balanceOf(minter.address)).to.bignumber.eq(new BN(0));
        });
      });
    });
  }
});
