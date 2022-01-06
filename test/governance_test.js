const { expect } = require("chai");
const { ethers } = require("hardhat");
let signers;
let Governance;
let governance;
let contractAddress; 

beforeEach(async () => {
  signers = await ethers.getSigners();
  Governance = await ethers.getContractFactory("governance");
  governance = await Governance.deploy(20000);
  await governance.deployed();
  contractAddress = governance.address;
});
describe('governance', () => {
    it("should ")
});