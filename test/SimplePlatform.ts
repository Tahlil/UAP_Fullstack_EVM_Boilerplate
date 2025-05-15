import { ethers } from "hardhat";
import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { SimplePlatform, SimplePlatform__factory } from "../frontend/typechain";

describe("SimplePlatform", () => {
  async function deployOnceFixture() {
    const [owner, ...otherAccounts] = await ethers.getSigners();
    const simplePlatform: SimplePlatform = await new SimplePlatform__factory(owner).deploy();
    return { simplePlatform, owner, otherAccounts };
  }

  it("Should set the correct owner", async () => {
    const { simplePlatform, owner } = await loadFixture(deployOnceFixture);
    expect(await simplePlatform.owner()).to.equal(owner.address);
  });

  it("Should allow deposits and emit event", async () => {
    const { simplePlatform, otherAccounts } = await loadFixture(deployOnceFixture);
    const user = otherAccounts[0];
    const depositAmount = ethers.utils.parseEther("1");

    const tx = await simplePlatform.connect(user).deposit({ value: depositAmount });
    await tx.wait();

    expect(await simplePlatform.balances(user.address)).to.equal(depositAmount);
  });

  it("Should reject zero deposits", async () => {
    const { simplePlatform, otherAccounts } = await loadFixture(deployOnceFixture);
    const user = otherAccounts[0];

    await expect(simplePlatform.connect(user).deposit({ value: 0 }))
      .to.be.revertedWith("Zero deposit not allowed");
  });

  it("Should withdraw correct amount and emit event", async () => {
    const { simplePlatform, otherAccounts } = await loadFixture(deployOnceFixture);
    const user = otherAccounts[0];
    const depositAmount = ethers.utils.parseEther("2");
    const withdrawAmount = ethers.utils.parseEther("1");

    await simplePlatform.connect(user).deposit({ value: depositAmount });
    const tx = await simplePlatform.connect(user).withdraw(withdrawAmount);
    await tx.wait();

    const finalBalance = await simplePlatform.balances(user.address);
    expect(finalBalance).to.equal(Number(depositAmount) - Number(withdrawAmount));
  });

  it("Should reject withdrawal exceeding balance", async () => {
    const { simplePlatform, otherAccounts } = await loadFixture(deployOnceFixture);
    const user = otherAccounts[0];
    const depositAmount = ethers.utils.parseEther("1");
    const withdrawAmount = ethers.utils.parseEther("2");

    await simplePlatform.connect(user).deposit({ value: depositAmount });

    await expect(simplePlatform.connect(user).withdraw(withdrawAmount))
      .to.be.revertedWith("Insufficient balance");
  });

  it("Should reject zero withdrawal", async () => {
    const { simplePlatform, otherAccounts } = await loadFixture(deployOnceFixture);
    const user = otherAccounts[0];

    await expect(simplePlatform.connect(user).withdraw(0))
      .to.be.revertedWith("Zero withdraw not allowed");
  });

  it("Should return correct balance for user", async () => {
    const { simplePlatform, otherAccounts } = await loadFixture(deployOnceFixture);
    const user = otherAccounts[0];
    const depositAmount = ethers.utils.parseEther("0.5");

    await simplePlatform.connect(user).deposit({ value: depositAmount });
    const balance = await simplePlatform.connect(user).getBalance();

    expect(balance).to.equal(depositAmount);
  });

  it("Should receive ether in contract", async () => {
    const { simplePlatform, otherAccounts } = await loadFixture(deployOnceFixture);
    const user = otherAccounts[0];
    const depositAmount = ethers.utils.parseEther("0.2");

    await simplePlatform.connect(user).deposit({ value: depositAmount });

    const contractBalance = await ethers.provider.getBalance(await simplePlatform.address);
    expect(contractBalance).to.equal(depositAmount);
  });
});
