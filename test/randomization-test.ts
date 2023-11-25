import { expect } from "chai"
import { ethers } from "hardhat"
import { RandomizationMock } from "../typechain-types"

describe("Randomization", function () {

	let randomization: RandomizationMock
	let initialSeed = "0x539187bb598210e39a0ce712c11efa26d9756b00698d2f52e64df6a2534e65b5"

	beforeEach(async () => {
		const Randomization = await ethers.getContractFactory("RandomizationMock")
		randomization = await Randomization.deploy(initialSeed)
		await randomization.waitForDeployment()
	})

	it("Should fail with PercentagesGreaterThan100", async function() {
		const percentages = [38, 33, 19, 11] // This adds up to 101 (last should be 10)
		for (var i = 0; i <= 25; i++) {
			await expect(randomization.randomIndex(i, percentages), `i=${i}`).to.be.revertedWithCustomError(randomization, "PercentagesGreaterThan100")
		}
		for (var i = 26; i < 256; i++) {
			await expect(randomization.randomIndex(i, percentages), `i=${i}`).to.not.be.reverted
		}
	})

	it("Should return random values matching percentages with implied last percentage", async function() {
		const percentages = [38, 33, 19, 9] // last of 1 is implied
		var buckets = [0, 0, 0, 0, 0]
		for (var i = 0; i < 255; i++) {
			var bucket = await randomization.randomIndex(i, percentages)
			buckets[Number(bucket)] += 1
		}
		for (var i = 0; i < buckets.length; i++) {
			var result = buckets[i] * 100 / 255
			var expected = i < percentages.length ? percentages[i] : 1
			// console.log(`bucket ${i} = ${result}`)
			expect(result, `bucket ${i}`).to.be.closeTo(expected, 1)
		}
	})

	it("Should return random values matching percentages with explicit last percentage", async function() {
		const percentages = [38, 33, 19, 9, 1]
		var buckets = [0, 0, 0, 0, 0]
		for (var i = 0; i < 255; i++) {
			var bucket = await randomization.randomIndex(i, percentages)
			buckets[Number(bucket)] += 1
		}
		for (var i = 0; i < buckets.length; i++) {
			var result = buckets[i] * 100 / 255
			var expected = i < percentages.length ? percentages[i] : 1
			// console.log(`bucket ${i} = ${result}`)
			expect(result, `bucket ${i}`).to.be.closeTo(expected, 1)
		}
	})

	it("Should fill buckets matching within 10% of one standard deviation", async function() {
		// Note that this is not a statistically refined test. There is room for improvement
		var seed = initialSeed
		var buckets = new Map<number, number>()
		for (var i = 0; i < 255; i++) {
			var nextSeed = await randomization.randomSeed(seed)
			var bucket = parseInt((nextSeed & 0xFFn).toString())
			var count = buckets.get(bucket)
			if (count === null || count === undefined) {
				buckets.set(bucket, 1)
			} else {
				buckets.set(bucket, count + 1)
			}
			seed = nextSeed.toString()
		}
		var bucketCount = buckets.size
		// console.log(`BucketCount = ${bucketCount}`)
		// 1 standard deviation (68.27%) should be ~175 -- let's be "close" to it
		expect(bucketCount).to.be.closeTo(175, 25)
	})

	it("Should report gas for randomSeed()", async function() {
		var promises = new Array<Promise<any>>()
		for (var i = 0; i < 10; i++) {
			promises.push(randomization.randomSeedCost())
		}
		await expect(Promise.all(promises)).to.not.be.reverted
	})
})
