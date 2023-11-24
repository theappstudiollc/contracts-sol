import { expect } from "chai"
import { ethers } from "hardhat"
import { OnChainMock } from "../typechain-types"

describe("OnChain", function () {

	let onChain: OnChainMock

	beforeEach(async () => {
		const OnChain = await ethers.getContractFactory("OnChainMock")
		onChain = await OnChain.deploy()
		await onChain.waitForDeployment()
	})

	it("Should be base uri suitable for on-chain metadata", async function() {
		expect(await onChain.baseURI()).to.be.equal("data:application/json;base64,")
	})

	it("Should be base uri suitable for on-chain svg", async function() {
		expect(await onChain.baseSvgImageURI()).to.be.equal("data:image/svg+xml;base64,")
	})

	it("Should be attribute pair suitable for on-chain metadata attributes", async function() {
		var name = "Name", value = "Dave"
		expectValidJson(await onChain.traitAttribute(name, value), "trait_type", "value")
		expect(await onChain.traitAttribute(name, value)).to.be.equal(`{"trait_type":"${name}","value":"${value}"}`)
	})

	it("Should join contents with a comma", async function() {
		expect(await onChain["commaSeparated(string,string)"]("", "")).to.be.equal(",")
		expect(await onChain["commaSeparated(string,string)"]("test1", "test2")).to.be.equal("test1,test2")

		expect(await onChain["commaSeparated(string,string,string)"]("", "", "")).to.be.equal(",,")
		expect(await onChain["commaSeparated(string,string,string)"]("test1", "test2", "test3")).to.be.equal("test1,test2,test3")

		expect(await onChain["commaSeparated(string,string,string,string)"]("", "", "", "")).to.be.equal(",,,")
		expect(await onChain["commaSeparated(string,string,string,string)"]("test1", "test2", "test3", "test4")).to.be.equal("test1,test2,test3,test4")

		expect(await onChain["commaSeparated(string,string,string,string,string)"]("", "", "", "", "")).to.be.equal(",,,,")
		expect(await onChain["commaSeparated(string,string,string,string,string)"]("test1", "test2", "test3", "test4", "test5")).to.be.equal("test1,test2,test3,test4,test5")

		expect(await onChain["commaSeparated(string,string,string,string,string,string)"]("", "", "", "", "", "")).to.be.equal(",,,,,")
		expect(await onChain["commaSeparated(string,string,string,string,string,string)"]("test1", "test2", "test3", "test4", "test5", "test6")).to.be.equal("test1,test2,test3,test4,test5,test6")
	})

	it("Should be contents prefixed with a comma", async function() {
		expect(await onChain.continuesWith("")).to.be.equal(`,`)
		expect(await onChain.continuesWith("test")).to.be.equal(`,test`)
	})

	it("Should be contents surrounded in squiggly brackets", async function() {
		expect(await onChain.dictionary("")).to.be.equal(`{}`)
		expect(await onChain.dictionary("test")).to.be.equal(`{test}`)
	})

	it("Should be key/value pair with an array value", async function() {
		expect(await onChain.keyValueArray("", "")).to.be.equal(`"":[]`)
		expect(await onChain.keyValueArray("key", "array")).to.be.equal(`"key":[array]`)
	})

	it("Should be key/value pair with a string value", async function() {
		expect(await onChain.keyValueString("", "")).to.be.equal(`"":""`)
		expect(await onChain.keyValueString("key", "string")).to.be.equal(`"key":"string"`)
	})

	it("Should be an encoded SVG image URI", async function() {
		var svg = simpleSvgImage()
		var encoded = await onChain.svgImageURI(svg)
		var buffer = Buffer.from(svg, 'utf-8')
		expect(encoded).to.be.equal(`data:image/svg+xml;base64,${buffer.toString('base64')}`)
	})

	it("Should combine into valid metadata", async function() {
		var metadata = await simpleNftMetadata()
		expectValidJson(metadata, "name", "attributes", "image")
	})

	it("Should be an encoded metadata URI", async function() {
		var metadata = await simpleNftMetadata()
		var encoded = await onChain.tokenURI(metadata)
		var buffer = Buffer.from(metadata, 'utf-8')
		expect(encoded).to.be.equal(`data:application/json;base64,${buffer.toString('base64')}`)
	})

	async function simpleNftMetadata() {
		var name = await onChain.keyValueString("name", "nft")
		var colorAttribute = await onChain.traitAttribute("color", "blue")
		var sizeAttribute = await onChain.traitAttribute("size", "small")
		var attributes = await onChain.keyValueArray("attributes", `${colorAttribute}${await onChain.continuesWith(sizeAttribute)}`)
		var image = await onChain.keyValueString("image", await onChain.svgImageURI(simpleSvgImage()))
		var contents = `${name}${await onChain.continuesWith(attributes)}${await onChain.continuesWith(image)}`
		return await onChain.dictionary(contents)
	}

	function simpleSvgImage() {
		return "<svg viewBox='0 0 1 2' xmlns='http://www.w3.org/2000/svg' version='1.1'><path id='bottom' d='M0 2 L1 2 1 1 0 1 Z' fill='rgb(65,176,246)'/><path id='top' d='M0 1 L1 1 1 0 0 0 Z' fill='rgb(240,240,240)'/></svg>"
	}

	var expectValidJson = (input: string, ...expectedKeys: string[]) => {
		// console.log(`input = ${input}`)
		var json = JSON.parse(input)
		expect(json).to.not.be.null
		expect(json).to.not.be.undefined
		expectedKeys.forEach(expectedKey => {
			// console.log(`Checking key ${expectedKey} = ${json[expectedKey]}`)
			expect(json[expectedKey], `failed key = ${expectedKey}`).to.not.be.undefined
		})
	}
})
