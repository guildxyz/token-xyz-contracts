const { utils } = require("ethers");
const { BN, expectEvent, expectRevert, time } = require("@openzeppelin/test-helpers");
const expect = require("chai").expect;

const InitialMigration = artifacts.require("InitialMigration");
const TokenXyz = artifacts.require("TokenXyz");
const ITokenXyz = artifacts.require("ITokenXyz");
const SimpleFunctionRegistryFeature = artifacts.require("SimpleFunctionRegistryFeature");
const OwnableFeature = artifacts.require("OwnableFeature");
const ERC721MerkleDropFactoryFeature = artifacts.require("ERC721MerkleDropFactoryFeature");
const ERC721MerkleDrop = artifacts.require("ERC721MerkleDrop");
const ERC721BatchMerkleDrop = artifacts.require("ERC721BatchMerkleDrop");

const randomRoot = "0xf7f77ea15719ea30bd2a584962ab273b1116f0e70fe80bbb0b30557d0addb7f3";
const nftMetadata0 = {
  name: "NFTXYZ",
  symbol: "XYZ",
  ipfsHash: "QmPaZD7i8TpLEeGjHtGoXe4mPKbRNNt8YTHH5nrKoqz9wJ",
  maxSupply: "42"
};
const nftMetadata1 = {
  name: "SOMENFTXYZ",
  symbol: "SNFT",
  ipfsHash: "QmPaZD7i8TpLEeGjHtGoXe4mPKbRNNt8YTHH5nrKoqz9wJ",
  maxSupply: "36"
};

contract("ERC721MerkleDropFactory", function (accounts) {
  const [wallet0, wallet1] = accounts;
  let tokenXyz;
  let erc721MerkleDropFactory;

  before("deploy contracts", async function () {
    const initialMigration = await InitialMigration.new(wallet0);
    tokenXyz = await TokenXyz.new(initialMigration.address);
    tokenXyz = await ITokenXyz.at(tokenXyz.address);
    const functionRegistry = await SimpleFunctionRegistryFeature.new();
    const ownable = await OwnableFeature.new();
    const features = {
      registry: functionRegistry.address,
      ownable: ownable.address
    };
    await initialMigration.initializeTokenXyz(wallet0, tokenXyz.address, features);
    erc721MerkleDropFactory = await ERC721MerkleDropFactoryFeature.new();
    const migrateInterface = new utils.Interface(["function migrate()"]);
    await tokenXyz.migrate(erc721MerkleDropFactory.address, migrateInterface.encodeFunctionData("migrate()"), wallet0);
  });

  it("saves deployed NFTs' addresses", async function () {
    await tokenXyz.createNFTMerkleDrop("Alice", randomRoot, new BN(86400), nftMetadata0, true, wallet0);
    await tokenXyz.createNFTMerkleDrop("Alice", randomRoot, new BN(86400), nftMetadata1, false, wallet0, {
      from: wallet1
    });
    await tokenXyz.createNFTMerkleDrop("Bob", randomRoot, new BN(604800), nftMetadata0, false, wallet1, {
      from: wallet1
    });
    const nftAddressesAlice = await tokenXyz.getDeployedNFTMerkleDrops("Alice");
    const nftAddressesBob = await tokenXyz.getDeployedNFTMerkleDrops("Bob");
    const factoryVersion = await erc721MerkleDropFactory.FEATURE_VERSION();
    expect(nftAddressesAlice.length).to.eq(2);
    expect(nftAddressesBob.length).to.eq(1);
    expect(nftAddressesAlice[0].factoryVersion).to.bignumber.eq(factoryVersion);
    expect(nftAddressesAlice[1].factoryVersion).to.bignumber.eq(factoryVersion);
    expect(nftAddressesBob[0].factoryVersion).to.bignumber.eq(factoryVersion);
  });

  it("passes correct parameters for NFT creation", async function () {
    const nftAddressesAlice = await tokenXyz.getDeployedNFTMerkleDrops("Alice");
    const nftAddressesBob = await tokenXyz.getDeployedNFTMerkleDrops("Bob");
    const nftAlice0 = await ERC721MerkleDrop.at(nftAddressesAlice[0].contractAddress);
    const nftAlice1 = await ERC721MerkleDrop.at(nftAddressesAlice[1].contractAddress);
    const nftBob0 = await ERC721MerkleDrop.at(nftAddressesBob[0].contractAddress);
    const blockTime = await time.latest();
    expect(await nftAlice0.merkleRoot()).to.eq(randomRoot);
    expect(await nftAlice1.merkleRoot()).to.eq(randomRoot);
    expect(await nftBob0.merkleRoot()).to.eq(randomRoot);
    expect(await nftAlice0.distributionEnd()).to.bignumber.closeTo(blockTime.add(new BN(86400)), "60");
    expect(await nftAlice1.distributionEnd()).to.bignumber.closeTo(blockTime.add(new BN(86400)), "60");
    expect(await nftBob0.distributionEnd()).to.bignumber.closeTo(blockTime.add(new BN(604800)), "60");
    expect(await nftAlice0.owner()).to.eq(wallet0);
    expect(await nftAlice1.owner()).to.eq(wallet0);
    expect(await nftBob0.owner()).to.eq(wallet1);
    expect(await nftAlice0.name()).to.eq(nftMetadata0.name);
    expect(await nftAlice0.symbol()).to.eq(nftMetadata0.symbol);
    expect(await nftAlice0.maxSupply()).to.bignumber.eq(nftMetadata0.maxSupply);
    expect(await nftAlice1.name()).to.eq(nftMetadata1.name);
    expect(await nftAlice1.symbol()).to.eq(nftMetadata1.symbol);
    expect(await nftAlice1.maxSupply()).bignumber.to.eq(nftMetadata1.maxSupply);
    expect(await nftBob0.name()).to.eq(nftMetadata0.name);
    expect(await nftBob0.symbol()).to.eq(nftMetadata0.symbol);
    expect(await nftBob0.maxSupply()).to.bignumber.eq(nftMetadata0.maxSupply);
  });

  it("deploys different contracts based on parameter and they are not mintable by anyone but the owner", async function () {
    await tokenXyz.createNFTMerkleDrop("Alice", randomRoot, new BN(86400), nftMetadata1, true, wallet0); // specific ID
    await tokenXyz.createNFTMerkleDrop("Alice", randomRoot, new BN(86400), nftMetadata1, false, wallet0); // batch
    const nftAddressesAlice = await tokenXyz.getDeployedNFTMerkleDrops("Alice");
    // create artifacts with the right and the other interface too
    const nftAliceSpecific = await ERC721MerkleDrop.at(
      nftAddressesAlice[[nftAddressesAlice.length - 2]].contractAddress
    );
    const nftAliceBatch = await ERC721BatchMerkleDrop.at(
      nftAddressesAlice[[nftAddressesAlice.length - 1]].contractAddress
    );
    const nftAliceSpecificWrong = await ERC721BatchMerkleDrop.at(nftAliceSpecific.address);
    const nftAliceBatchWrong = await ERC721MerkleDrop.at(nftAliceBatch.address);
    await expectRevert(nftAliceSpecific.safeMint(wallet0, "0", { from: wallet1 }), "Ownable: caller is not the owner");
    await expectRevert(nftAliceBatch.safeMint(wallet0, { from: wallet1 }), "Ownable: caller is not the owner");
    await expectRevert.unspecified(nftAliceSpecificWrong.safeMint(wallet0));
    await expectRevert.unspecified(nftAliceBatchWrong.safeMint(wallet0, "1"));
  });

  it("emits ERC721MerkleDropDeployed event", async function () {
    const res0 = await tokenXyz.createNFTMerkleDrop("Alice", randomRoot, new BN(86400), nftMetadata1, true, wallet0);
    const res1 = await tokenXyz.createNFTMerkleDrop("Bob", randomRoot, new BN(604800), nftMetadata1, false, wallet1, {
      from: wallet1
    });
    const nftAddressesAlice = await tokenXyz.getDeployedNFTMerkleDrops("Alice");
    const nftAddressesBob = await tokenXyz.getDeployedNFTMerkleDrops("Bob");
    const factoryVersion = await erc721MerkleDropFactory.FEATURE_VERSION();
    await expectEvent(res0.receipt, "ERC721MerkleDropDeployed", {
      deployer: wallet0,
      urlName: "Alice",
      instance: nftAddressesAlice[nftAddressesAlice.length - 1].contractAddress,
      factoryVersion: factoryVersion
    });
    await expectEvent(res1.receipt, "ERC721MerkleDropDeployed", {
      deployer: wallet1,
      urlName: "Bob",
      instance: nftAddressesBob[nftAddressesBob.length - 1].contractAddress,
      factoryVersion: factoryVersion
    });
  });
});
