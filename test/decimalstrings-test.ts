import { expect } from "chai"
import { ethers } from "hardhat"
import { DecimalStringsMock, DecimalStringsMock__factory } from "../typechain-types"

describe("DecimalStrings", function () {

	let decimalStrings: DecimalStringsMock

	beforeEach(async () => {
		// Deploy DecimalStringsMock
		const DecimalStringsMock = await ethers.getContractFactory("DecimalStringsMock") as DecimalStringsMock__factory
		decimalStrings = await DecimalStringsMock.deploy()
		await decimalStrings.waitForDeployment()
	})

	it("Should return formatted number as string with 0 to 18 decimals", async function () {

		for (var decimal = 0; decimal < 18; decimal++) {
			var divisor = 10 ** decimal
			for (const value of [1, 10, 100, 1234, 987654321, 9876543210]) {
				var expected = (value / divisor).toFixed(decimal)
				var isNegative = value < 0
				var description = `toDecimalString(${Math.abs(value)},${decimal},${isNegative})`
				expect (await decimalStrings.toDecimalString(Math.abs(value), decimal, isNegative), description).to.be.equal(expected)
			}
		}
	})

	it("Should return negative formatted number as string with 0 to 18 decimals", async function () {

		for (var decimal = 0; decimal < 18; decimal++) {
			var divisor = 10 ** decimal
			for (const value of [-1, -10, -100, -1234, -987654321, -9876543210]) {
				var expected = (value / divisor).toFixed(decimal)
				var isNegative = value < 0
				var description = `toDecimalString(${Math.abs(value)},${decimal},${isNegative})`
				expect (await decimalStrings.toDecimalString(Math.abs(value), decimal, isNegative), description).to.be.equal(expected)
			}
		}
	})

	it("Should return 0 as string with 0 to 18 decimals", async function () {

		const value = 0
		for (var decimal = 0; decimal < 18; decimal++) {
			var divisor = 10 ** decimal
			var expected = (value / divisor).toFixed(decimal)
			var isNegative = value < 0
			var description = `toDecimalString(${Math.abs(value)},${decimal},${isNegative})`
			expect (await decimalStrings.toDecimalString(Math.abs(value), decimal, isNegative), description).to.be.equal(expected)
		}
	})
})
