import { expect } from "chai"
import { ethers } from "hardhat"
import { SignerWithAddress } from "@nomicfoundation/hardhat-ethers/signers"
import { SubscribableServiceMock } from "../typechain-types"
import { TransactionResponse, ZeroAddress } from "ethers"

describe("SubscribableService", function () {

	let subscribableService: SubscribableServiceMock
	let subscribableServiceAddress: string
	let subscriptionPrice = 0.01 // ETH

	beforeEach(async () => {
		const SubscribableService = await ethers.getContractFactory("SubscribableServiceMock")
		let wei = ethers.parseEther(subscriptionPrice.toString())
		subscribableService = await SubscribableService.deploy(wei)
		await subscribableService.waitForDeployment()
		subscribableServiceAddress = await subscribableService.getAddress()
	})

	it("Should return subscription price", async function() {
		let wei = ethers.parseEther(subscriptionPrice.toString())
		expect(await subscribableService.subscriptionPrice()).to.be.equal(wei)
	})

	it("Should change subscriptionPrice", async function() {
		let newPrice = subscriptionPrice * 2
		let wei = ethers.parseEther(newPrice.toString())
		await subscribableService.changePrice(wei)
		expect(await subscribableService.subscriptionPrice()).to.be.equal(wei)
	})

	it("Should revert with AddressAlreadySubscribed", async function() {
		var price = await subscribableService.subscriptionPrice()
		await subscribableService.subscribe(subscribableServiceAddress, { value: price })
		await expect(subscribableService.subscribe(subscribableServiceAddress, { value: price })).to.be.revertedWithCustomError(subscribableService, "AddressAlreadySubscribed")
	})

	it("Should revert with CallerNotSubscribed", async function() {
		await expect(subscribableService.subscribableServiceFunction()).to.be.revertedWithCustomError(subscribableService, "CallerNotSubscribed")
	})

	it("Should revert with InvalidSubscriptionPrice", async function() {
		var price = await subscribableService.subscriptionPrice()
		await expect(subscribableService.subscribe(subscribableServiceAddress, { value: price - 1n })).to.be.revertedWithCustomError(subscribableService, "InvalidSubscriptionPrice")
	})

	it("Should return not subscribed", async function() {
		expect(await subscribableService.isSubscribed(subscribableServiceAddress)).to.be.false
	})

	it("Should return subscribed", async function() {
		var price = await subscribableService.subscriptionPrice()
		await subscribableService.subscribe(subscribableServiceAddress, { value: price })
		expect(await subscribableService.isSubscribed(subscribableServiceAddress)).to.be.true
	})

	it("Should return correct collected fees", async function() {
		expect(await subscribableService.collectedFees()).to.be.equal(0)
		var price = await subscribableService.subscriptionPrice()
		await subscribableService.subscribe(subscribableServiceAddress, { value: price })
		expect(await subscribableService.collectedFees()).to.be.equal(price)
	})

	it("Should withdraw all fees", async function() {
		// Subscribe to add some collected fees
		var price = await subscribableService.subscriptionPrice()
		await subscribableService.subscribe(subscribableServiceAddress, { value: price })
		// Capture the current owner's balance and withdraw
		const [owner] = await ethers.getSigners()
		var balance = await ethers.provider.getBalance(owner.address)
		await subscribableService.withdraw() // This incurs a gas cost on the owner
		// Verify balances and collected fees
		var updatedBalance = await ethers.provider.getBalance(owner.address)
		expect(updatedBalance > balance).to.be.true
		expect(await subscribableService.collectedFees()).to.be.equal(0)
	})

	it("Should return correct subscribers", async function() {
		expect(await subscribableService.currentSubscribers()).to.be.empty
		var price = await subscribableService.subscriptionPrice()
		await subscribableService.subscribe(subscribableServiceAddress, { value: price })
		var subscribers = await subscribableService.currentSubscribers()
		expect(subscribers).to.not.be.empty
		expect(subscribers[0]).to.be.equal(subscribableServiceAddress)
	})

	it("Should succeed with subscribable service call", async function() {
		const [owner] = await ethers.getSigners()
		var price = await subscribableService.subscriptionPrice()
		await subscribableService.subscribe(owner.address, { value: price })
		expect(await subscribableService.subscribableServiceFunction()).to.be.true
	})

	it("Should fail with OnlyOwner", async function () {
		var onlyOwner = "Ownable: caller is not the owner"
		await sendEth(1, ZeroAddress)
		const impersonatedSigner = await impersonate(ZeroAddress)
		await expect(subscribableService.connect(impersonatedSigner).changePrice(500)).to.be.revertedWith(onlyOwner)
		await expect(subscribableService.connect(impersonatedSigner).withdraw()).to.be.revertedWith(onlyOwner)
	})

	async function impersonate(account: string): Promise<SignerWithAddress> {
		await ethers.provider.send("hardhat_impersonateAccount", [account]);
		return ethers.getSigner(account)
	}

	async function sendAmount(amount: bigint, address: string): Promise<TransactionResponse> {
		const accounts = await ethers.getSigners()
		const signer = accounts[0]
		return signer.sendTransaction({ to: address, value: amount })
	}

	async function sendEth(ether: number, address: string): Promise<TransactionResponse> {
		return sendAmount(ethers.parseEther(ether.toString()), address)
	}
})
