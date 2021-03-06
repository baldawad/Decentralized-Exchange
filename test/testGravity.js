const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");

describe("GravityTrader", function () {
  let deployer, usdcTokenOwner, linkTokenOwner;

  let usdcToken;
  let linkToken;

  let GravityTrader;

  const initialSupply = ethers.utils.parseUnits("1000", 18);
  const intervalAmount = ethers.utils.parseUnits("100", 18);

  beforeEach(async function () {
    [deployer, usdcTokenOwner, linkTokenOwner] = await ethers.getSigners();

    const USDCToken = await ethers.getContractFactory("USDCToken", usdcTokenOwner);
    usdcToken = await USDCToken.deploy(initialSupply);

    await usdcToken.deployed();
    
  });

  beforeEach(async function () {
    [deployer, usdcTokenOwner, linkTokenOwner] = await ethers.getSigners();

    const LINKToken = await ethers.getContractFactory("LINKToken", usdcTokenOwner);
    linkToken = await LINKToken.deploy(initialSupply);

    await linkToken.deployed();
    
  });

  beforeEach(async function () {
    const GravityTrader = await ethers.getContractFactory("Gravity");
    gravityTrader = await GravityTrader.deploy();

    await gravityTrader.deployed();

    gravityTrader.addNewToken("USDCT",usdcToken.address);
    gravityTrader.addNewToken("LINKT",linkToken.address);
  });

  it.only("deposits erc20 token", async function () {
    gravityTrader = await gravityTrader.connect(usdcTokenOwner);
    
    await printBalances('before deposits');

    const approveTxn = await usdcToken.approve(gravityTrader.address, initialSupply);
    await approveTxn.wait();

    const depositTxn = await gravityTrader.initiateNewStrategy('USDCT','LINKT',initialSupply,intervalAmount,'Daily');
    await depositTxn.wait();

    let usdcTokenOwnerBalance = await usdcToken.balanceOf(usdcTokenOwner.address);
    let gravityTraderBalance = await usdcToken.balanceOf(gravityTrader.address);

    await printBalances("after deposits");

    expect(usdcTokenOwnerBalance).to.equal(ethers.BigNumber.from("0"));
    expect(gravityTraderBalance).to.equal(initialSupply);
  });

  it.only("withdraws erc20 token", async function () {
    gravityTrader = await gravityTrader.connect(usdcTokenOwner);
    
    await printBalances('before deposits');

    const approveTxn = await usdcToken.approve(gravityTrader.address, initialSupply);
    await approveTxn.wait();

    const depositTxn = await gravityTrader.initiateNewStrategy('USDCT','LINKT',initialSupply,intervalAmount,'Daily');
    await depositTxn.wait();

    await printBalances("after deposits");

    const withdrawTxn = await gravityTrader.withdraw(1,initialSupply);
    await withdrawTxn.wait();

    let usdcTokenOwnerBalance = await usdcToken.balanceOf(usdcTokenOwner.address);
    let gravityTraderBalance = await usdcToken.balanceOf(gravityTrader.address);

    await printBalances("after withdrawals");

    expect(usdcTokenOwnerBalance).to.equal(initialSupply);
    expect(gravityTraderBalance).to.equal(ethers.BigNumber.from("0"));
  });

  /*it("swaps with counterparty", async function () {
    gravityTrader = await gravityTrader.connect(usdcTokenOwner);

    await printBalances("before deposits");

    // 1. approve contract to spend MunchinToken on user's behalf
    let approveTxn = await munchinToken.approve(gravityTrader.address, initialSupply);
    await approveTxn.wait();

    // 2. deposit MunchinToken to contract
    const depositTxn = await gravityTrader.initiateNewStrategy('USDCT','LINKT',initialSupply,intervalAmount,'Daily');
    await depositTxn.wait();

    trustlessTrader = await trustlessTrader.connect(bengalTokenOwner);

    // 1. approve contract to spend BengalToken on user's behalf
    approveTxn = await bengalToken.approve(trustlessTrader.address, initialSupply);
    await approveTxn.wait();

    // 2. deposit BengalToken to contract
    depositTxn = await trustlessTrader.deposit(bengalToken.address, initialSupply);
    await depositTxn.wait();

    await printBalances("after deposits");

    // 3. perform trustlessTrader.tradeWith()

    trustlessTrader = await trustlessTrader.connect(munchinTokenOwner);

    const swapWithTxn = await trustlessTrader.tradeWith(bengalTokenOwner.address);
    await swapWithTxn.wait();

    await printBalances('after tradeWith()');
  });*/


  async function printBalances(msg) {
    usdcTokenOwnerUSDCBalance = await usdcToken.balanceOf(usdcTokenOwner.address);
    linkTokenOwnerUSDCBalance = await usdcToken.balanceOf(linkTokenOwner.address);
    gravityTraderUSDCBalance = await usdcToken.balanceOf(gravityTrader.address);

    usdcTokenOwnerlinkBalance = await linkToken.balanceOf(usdcTokenOwner.address);
    linkTokenOwnerlinkBalance = await linkToken.balanceOf(linkTokenOwner.address);
    gravityTraderlinkBalance = await linkToken.balanceOf(gravityTrader.address);

    console.log(`--------------------------------------------------`);
    console.log(`USDCToken Balances ${msg}`);
    console.log(`    usdcTokenOwner = ${ethers.utils.formatUnits(usdcTokenOwnerUSDCBalance, 18)}`);
    console.log(`    linkTokenOwner = ${ethers.utils.formatUnits(linkTokenOwnerUSDCBalance, 18)}`);
    console.log(`    GravityTraderContract = ${ethers.utils.formatUnits(gravityTraderUSDCBalance, 18)}`);

    console.log(`--------------------------------------------------`);
    console.log(`LINKToken Balances ${msg}`);
    console.log(`    usdcTokenOwner = ${ethers.utils.formatUnits(usdcTokenOwnerlinkBalance, 18)}`);
    console.log(`    linkTokenOwner = ${ethers.utils.formatUnits(linkTokenOwnerlinkBalance, 18)}`);
    console.log(`    GravityTraderContract = ${ethers.utils.formatUnits(gravityTraderlinkBalance, 18)}`);
  }
});
