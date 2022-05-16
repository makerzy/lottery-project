import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import chai, { expect } from "chai";
import { solidity } from "ethereum-waffle";
import { Contract } from "ethers";
import { ethers } from "hardhat";
import { beforeEach, describe } from "mocha";
import { expandTo18 } from "./utils/bignumber";

chai.use(solidity);
let accounts: SignerWithAddress[],
  wallet: SignerWithAddress,
  other0: SignerWithAddress,
  other1: SignerWithAddress,
  other2: SignerWithAddress,
  other3: SignerWithAddress,
  other4: SignerWithAddress,
  other5: SignerWithAddress,
  other6: SignerWithAddress;

let token: Contract, lottery: Contract;
describe("Lottery", () => {
  beforeEach("Transaction", async () => {
    accounts = await ethers.getSigners();
    [wallet, other0, other1, other2, other3, other4, other5, other6] = accounts;
    const Lottery = await ethers.getContractFactory("Lottery", wallet);
    const Token = await ethers.getContractFactory("MyToken", wallet);
    token = await Token.deploy();
    lottery = await Lottery.deploy(token.address);
    await Promise.all([token.deployed(), lottery.deployed()]);
  });
  describe("Transaction", () => {
    it("deploy", async () => {
      expect(await lottery.owner()).to.equal(wallet.address);
      expect(await token.balanceOf(wallet.address)).to.equal(expandTo18(10000));
      expect(await token.totalSupply()).to.equal(expandTo18(10000));
    });
  });
});
