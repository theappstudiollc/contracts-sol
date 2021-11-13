const { expect } = require("chai")
const { ethers } = require("hardhat")

describe("SubscribableService", function () {

    let subscribableService
    let subscriptionPrice = 0.01 // ETH

    beforeEach(async () => {
        const SubscribableService = await ethers.getContractFactory("SubscribableServiceMock")
        let wei = ethers.utils.parseEther(subscriptionPrice.toString())
        subscribableService = await SubscribableService.deploy(wei)
        await subscribableService.deployed()
    })

    it("Should return subscription price", async function() {
        let wei = ethers.utils.parseEther(subscriptionPrice.toString())
        expect(await subscribableService.subscriptionPrice()).to.be.equal(wei)
    })

    it("Should change subscriptionPrice", async function() {
        let newPrice = subscriptionPrice * 2
        let wei = ethers.utils.parseEther(newPrice.toString())
        await subscribableService.changePrice(wei)
        expect(await subscribableService.subscriptionPrice()).to.be.equal(wei)
    })

    it("Should revert with AddressAlreadySubscribed", async function() {
        var price = await subscribableService.subscriptionPrice()
        await subscribableService.subscribe(subscribableService.address, { value: price })
        await expect(subscribableService.subscribe(subscribableService.address, { value: price })).to.be.revertedWith("AddressAlreadySubscribed")
    })

    it("Should revert with CallerNotSubscribed", async function() {
        await expect(subscribableService.subscribableServiceFunction()).to.be.revertedWith("CallerNotSubscribed")
    })

    it("Should revert with InvalidSubscriptionPrice", async function() {
        var price = await subscribableService.subscriptionPrice()
        await expect(subscribableService.subscribe(subscribableService.address, { value: price.sub(1) })).to.be.revertedWith("InvalidSubscriptionPrice")
    })

    it("Should return not subscribed", async function() {
        expect(await subscribableService.isSubscribed(subscribableService.address)).to.be.false
    })

    it("Should return subscribed", async function() {
        var price = await subscribableService.subscriptionPrice()
        await subscribableService.subscribe(subscribableService.address, { value: price })
        expect(await subscribableService.isSubscribed(subscribableService.address)).to.be.true
    })

    it("Should return correct collected fees", async function() {
        expect(await subscribableService.collectedFees()).to.be.equal(0)
        var price = await subscribableService.subscriptionPrice()
        await subscribableService.subscribe(subscribableService.address, { value: price })
        expect(await subscribableService.collectedFees()).to.be.equal(price)
    })

    it("Should withdraw all fees", async function() {
        // Subscribe to add some collected fees
        var price = await subscribableService.subscriptionPrice()
        await subscribableService.subscribe(subscribableService.address, { value: price })
        // Capture the current owner's balance and withdraw
        const [owner] = await ethers.getSigners()
        var balance = await ethers.provider.getBalance(owner.address);
        await subscribableService.withdraw() // This incurs a gas cost on the owner
        // Verify balances and collected fees
        var updatedBalance = await ethers.provider.getBalance(owner.address)
        expect(updatedBalance.gt(balance)).to.be.true
        expect(await subscribableService.collectedFees()).to.be.equal(0)
    })

    it("Should return correct subscribers", async function() {
        expect(await subscribableService.currentSubscribers()).to.be.empty
        var price = await subscribableService.subscriptionPrice()
        await subscribableService.subscribe(subscribableService.address, { value: price })
        var subscribers = await subscribableService.currentSubscribers()
        expect(subscribers).to.not.be.empty
        expect(subscribers[0]).to.be.equal(subscribableService.address)
    })

    it("Should succeed with subscribable service call", async function() {
        const [owner] = await ethers.getSigners()
        var price = await subscribableService.subscriptionPrice()
        await subscribableService.subscribe(owner.address, { value: price })
        expect(await subscribableService.subscribableServiceFunction()).to.be.true
    })
})
