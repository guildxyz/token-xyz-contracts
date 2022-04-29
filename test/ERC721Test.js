const { BN, expectRevert } = require("@openzeppelin/test-helpers");
const expect = require("chai").expect;

const ERC721 = artifacts.require("ERC721Mintable");
const ERC721AutoIdBatchMint = artifacts.require("ERC721AutoIdBatchMint");

const tokenName = "OwoNFT";
const tokenSymbol = "OFT";
const tokenCid = "QmPaZD7i8TpLEeGjHtGoXe4mPKbRNNt8YTHH5nrKoqz9wJ";
const tokenMaxSupply = "3";

const runOptions = [
  {
    context: "NFT with auto-incremented IDs",
    ERC721: ERC721AutoIdBatchMint
  },
  {
    context: "NFT with arbitrary IDs",
    ERC721: ERC721
  }
];

contract("ERC721 contracts", function (accounts) {
  const [wallet0, wallet1] = accounts;

  for (const runOption of runOptions) {
    context(runOption.context, function () {
      let token;

      beforeEach("create a token", async function () {
        token = await runOption.ERC721.new(tokenName, tokenSymbol, tokenCid, tokenMaxSupply);
      });

      it("should have correct metadata & owner", async function () {
        const name = await token.name();
        const symbol = await token.symbol();
        const maxSupply = await token.maxSupply();
        const owner = await token.owner();
        expect(name).to.eq(tokenName);
        expect(symbol).to.eq(tokenSymbol);
        expect(maxSupply).to.bignumber.eq(tokenMaxSupply);
        expect(owner).to.eq(wallet0);
      });

      it("should have zero tokens initially", async function () {
        const totalSupply = await token.totalSupply();
        expect(totalSupply).to.bignumber.eq("0");
      });

      it("should return the correct tokenURI", async function () {
        if (runOption.context.includes("auto-incremented IDs")) await token.safeMint(wallet1);
        else await token.safeMint(wallet1, 0);
        const regex = new RegExp(`ipfs:\/\/${tokenCid}\/0.json`);
        expect(regex.test(await token.tokenURI(0))).to.be.true;
      });

      it("should revert when trying to get the tokenURI for a non-existent token", async function () {
        // error NonExistentToken(uint256 tokenId);
        expectRevert.unspecified(token.tokenURI(84));
      });

      it("should really be mintable", async function () {
        const oldBalance = await token.balanceOf(wallet1);
        if (runOption.context.includes("auto-incremented IDs")) await token.safeMint(wallet1);
        else await token.safeMint(wallet1, 0);
        const newBalance = await token.balanceOf(wallet1);
        expect(newBalance).to.bignumber.eq(oldBalance.add(new BN(1)));
      });

      it("should not be possible to mint a token with the same ID twice", async function () {
        if (runOption.context.includes("auto-incremented IDs")) expect(true).to.be.true; // trivial
        else {
          await token.safeMint(wallet0, 0);
          await expectRevert(token.safeMint(wallet0, 0), "ERC721: token already minted");
        }
      });

      it("minting increases totalSupply", async function () {
        const totalSupply = await token.totalSupply();
        if (runOption.context.includes("auto-incremented IDs")) await token.safeMint(wallet0);
        else await token.safeMint(wallet0, 0);
        expect(await token.totalSupply()).to.bignumber.eq(totalSupply.add(new BN(1)));
      });

      it("should fail to mint above maxSupply", async function () {
        // error TokenIdOutOfBounds();
        if (runOption.context.includes("auto-incremented IDs")) {
          await token.safeMint(wallet0);
          await token.safeMint(wallet0);
          await token.safeMint(wallet0);
          await expectRevert.unspecified(token.safeMint(wallet0));
        } else await expectRevert.unspecified(token.safeMint(wallet0, 3));
      });

      if (runOption.context.includes("auto-incremented IDs")) {
        it("should batch transfer tokens", async function () {
          const amountToMint = new BN(2);
          const oldBalance = await token.balanceOf(wallet0);
          await token.safeBatchMint(wallet0, amountToMint);
          const newBalance = await token.balanceOf(wallet0);
          expect(newBalance).to.bignumber.eq(oldBalance.add(amountToMint));
          expect(await token.ownerOf(0)).to.eq(wallet0);
          expect(await token.ownerOf(1)).to.eq(wallet0);
        });
      }
    });
  }
});
