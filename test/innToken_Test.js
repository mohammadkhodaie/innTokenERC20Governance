const { expect } = require("chai");
const { ethers } = require("hardhat");
let signers;
let InnToken;
let innToken;
let contractAddress; 
beforeEach(async () => {
  signers = await ethers.getSigners();
  InnToken = await ethers.getContractFactory("innToken");
  innToken = await InnToken.deploy(20000);
  await innToken.deployed();
  contractAddress = innToken.address;
});

describe("innToken", function () {
  // it("should return the accounts" , async function() {
  //   signers = await ethers.getSigners();
  //   // console.log(signers[0]);
  // });
  
  it("should construct and mint and burn from creator", async function () {
    expect(await innToken.totalSupply()).to.equal(20000);
   
    const mintTx = await innToken.mint(10000);
    // wait until the transaction is mined
    await mintTx.wait();

    expect(await innToken.totalSupply()).to.equal(30000);

    const burnTX =  await innToken.burn(10000);
    await burnTX.wait();

    expect(await innToken.totalSupply()).to.equal(20000);

  });

  it("should not mint and burn from another account" , async function (){
    // await innToken.connect(signers[1]).mint(10000);
    // await mintTx.wait();
    // expect(await innToken.totalSupply()).to.equal(20000);

    await expect(
      innToken.connect(signers[1]).mint(10000)
    ).to.be.revertedWith("Ownable: caller is not the owner");

    await expect(
      innToken.connect(signers[1]).burn(10000)
    ).to.be.revertedWith("Ownable: caller is not the owner");
  });

  it("should transfer ownership and new owner should mint and burn" , async function (){
    await innToken.transferOwnership(signers[1].address);
    expect(await innToken.connect(signers[1]).allowance(contractAddress , signers[1].address)).to.equal(20000);
    expect(await innToken.connect(signers[1]).allowance(contractAddress , signers[0].address)).to.equal(0);
    await innToken.connect(signers[1]).mint(10000);
    expect(await innToken.connect(signers[1]).allowance(contractAddress , signers[1].address)).to.equal(30000);
    expect(await innToken.connect(signers[1]).allowance(contractAddress , signers[0].address)).to.equal(0);
    await innToken.connect(signers[1]).burn(10000);
    expect(await innToken.connect(signers[1]).allowance(contractAddress , signers[1].address)).to.equal(20000);
    expect(await innToken.connect(signers[1]).allowance(contractAddress , signers[0].address)).to.equal(0);
    await expect(
      innToken.connect(signers[0]).burn(10000)
    ).to.be.revertedWith("Ownable: caller is not the owner");

    //return to default state 
    // await innToken.connect(signers[1]).transferOwnership(signers[0].address);
    // expect(await innToken.owner()).to.equal(signers[0].address);
    // expect(await innToken.totalSupply()).to.equal(20000);
    // expect(await innToken.connect(signers[0]).allowance(contractAddress , signers[0].address)).to.equal(20000);

    // await innToken.connect(signers[0]).transferOwnership(signers[1].address);
    // expect(await innToken.owner()).to.equal(signers[1].address);
    // expect(await innToken.totalSupply()).to.equal(20000);
    // expect(await innToken.connect(signers[0]).allowance(contractAddress , signers[1].address)).to.equal(20000);

  });

  it("should transfer and increase and decrease allowance" , async function(){
    expect(await innToken.owner()).to.equal(signers[0].address);
    expect(await innToken.allowance(contractAddress , signers[0].address)).to.equal(20000);


    await innToken.transferFrom(contractAddress,signers[1].address , 10000);
    expect(await innToken.balanceOf(signers[1].address)).to.equal(10000);
    expect(await innToken.allowance(contractAddress,signers[0].address)).to.equal(10000);
    await expect (
       innToken.transferFrom(contractAddress,signers[1].address , 15000)
    ).to.be.revertedWith( "ERC20: transfer amount exceeds balance");
  });

  it("should freeze and unfreeze" , async function(){
    await innToken.transferFrom(contractAddress,signers[1].address , 10000);
    expect(await innToken.balanceOf(signers[1].address)).to.equal(10000);
    await innToken.freeze(signers[1].address , 5000);
    expect(await innToken.freezedOf(signers[1].address)).to.equal(5000);

    await expect (
      innToken.connect(signers[1]).transfer(signers[2].address , 7000)
    ).to.be.revertedWith( "ERC20: transfer amount exceeds balance");

    expect(await innToken.connect(signers[1]).transfer(signers[2].address , 3000)).to.ok;

    expect(await innToken.balanceOf(signers[1].address)).to.equal(2000);

    
  });

});
