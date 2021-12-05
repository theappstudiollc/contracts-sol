import { expect } from "chai"
import { ethers } from "hardhat"
import { SVGMock } from "../typechain-types"
import { ColorStruct, ColorStructOutput } from "../typechain-types/SVGMock"

describe("SVG", function () {

    let svg: SVGMock
    let black: ColorStruct = { red: 0x0, green: 0x0, blue: 0x0, alpha: 0xFF }
    let one: ColorStruct = { red: 0x1, green: 0x1, blue: 0x1, alpha: 0xFF }
    let white: ColorStruct = { red: 0xFF, green: 0xFF, blue: 0xFF, alpha: 0xFF }
    let zeroOneTwo: ColorStruct = { red: 0x0, green: 0x1, blue: 0x2, alpha: 0xFF }
    let middleRandom: ColorStruct = { red: 126, green: 126, blue: 128, alpha: 0xFF } // rgb even, results in 50%
    let brightestRandom: ColorStruct = { red: 254, green: 254, blue: 254, alpha: 0xFF } // rgb even, results in 100%

    beforeEach(async () => {
        const SVG = await ethers.getContractFactory("SVGMock")
        svg = await SVG.deploy()
        await svg.deployed()
    })

    it("Should be floor color", async function() {
        expectColorToEqual(await svg.randomizeColors(black, white, black), 0x000000)
        expectColorToEqual(await svg.randomizeColors(white, black, black), 0x000000)
    })

    it("Should be middle color", async function() {
        expectColorToEqual(await svg.randomizeColors(black, white, middleRandom), 0x7F7F7F)
        expectColorToEqual(await svg.randomizeColors(white, black, middleRandom), 0x7F7F7F)
    })

    it("Should be ceiling color", async function() {
        expectColorToEqual(await svg.randomizeColors(black, white, brightestRandom), 0xFFFFFF)
        expectColorToEqual(await svg.randomizeColors(white, black, brightestRandom), 0xFFFFFF)
    })

    it("Should not crash with tight color", async function() {
        expectColorToEqual(await svg.randomizeColors(black, black, { red: 0x43, green: 0x11, blue: 0xDA, alpha: 0xFF }), 0x000000, "1")
        expectColorToEqual(await svg.randomizeColors(black, one, { red: 0x43, green: 0x11, blue: 0xDA, alpha: 0xFF }), 0x000000, "2")
        expectColorToEqual(await svg.randomizeColors(one, one, { red: 0x43, green: 0x11, blue: 0xDA, alpha: 0xFF }), 0x010101, "3")
    })

    it("Should spread randomness evenly", async function() {
        // NOTE: Focus on one color component to ensure a fast test
        var redHash = new Map<number, number>()
        for (var component = 0; component < 256; component++) {
            var red = (await svg.randomizeColors(black, white, { red: component, green: component, blue: component, alpha: 0xFF })).red
            var count = redHash.get(red)
            if (count === null || count === undefined) {
                redHash.set(red, 1)
            } else {
                redHash.set(red, count + 1)
            }
        }
        // Each bucket of red should be within 1-3 (expecting 153 buckets)
        var valueHash = new Map<number, number>()
        for (let [, value] of redHash) {
            expect(value).to.be.closeTo(2, 1)
            var count = valueHash.get(value)
            if (count === null || count === undefined) {
                valueHash.set(value, 1)
            } else {
                valueHash.set(value, count + 1)
            }
        }
        // The counts within each bucket should be as tight a ratio as possible
        var bucketDistribution = redHash.size / (1 + 2 + 3) // = 25.5
        for (let [key, value] of valueHash) {
            expect(value).to.be.closeTo(bucketDistribution*(4-key), 0.5)
        }
    })

    it("Should generate proper svg attributes", async function () {
        var width = 180, height = 360
        expect(await svg.svgAttributes(width, height)).to.equal(` viewBox='0 0 ${width} ${height}' xmlns='http://www.w3.org/2000/svg'`)
    })

    it("Should generate proper path element", async function () {
        expect(await svg.createElement("path", "", "")).to.equal("<path/>")
        expect(await svg.createElement("path", " id='name'", "")).to.equal("<path id='name'/>")
        expect(await svg.createElement("path", "", "contents")).to.equal("<path>contents</path>")
        expect(await svg.createElement("path", " id='name'", "contents")).to.equal("<path id='name'>contents</path>")
    })

    it("Should generate rgb color attribute values", async function () {
        expect(await svg.colorAttributeRGBValue(black)).to.equal("rgb(0,0,0)")
        expect(await svg.colorAttributeRGBValue(one)).to.equal("rgb(1,1,1)")
        expect(await svg.colorAttributeRGBValue(zeroOneTwo)).to.equal("rgb(0,1,2)")
        expect(await svg.colorAttributeRGBValue(white)).to.equal("rgb(255,255,255)")
    })

    it("Should generate url color attribute values", async function () {
        expect(await svg.colorAttributeURLValue("testId")).to.equal("url(#testId)")
    })

    it("Should generate correct svg color attribute strings", async function () {
        var rgbColor = await svg.colorAttributeRGBValue(zeroOneTwo)
        expect(await svg.colorAttribute(0, rgbColor)).to.equal(" fill='rgb(0,1,2)'")
        expect(await svg.colorAttribute(1, rgbColor)).to.equal(" stroke='rgb(0,1,2)'")
        expect(await svg.colorAttribute(2, rgbColor)).to.equal(" stop-color='rgb(0,1,2)'")
    })

    it("Should correctly convert packed colors", async function() {
        expectColorToEqual(await svg.fromPackedColor(0x000000), 0x000000, "black")
        expectColorToEqual(await svg.fromPackedColor(0x010101), 0x010101, "one")
        expectColorToEqual(await svg.fromPackedColor(0xFFFFFF), 0xFFFFFF, "white")
    })

    it("Should generate svg color type error", async function () {
        var rgbColor = await svg.colorAttributeRGBValue(zeroOneTwo)
        await expect(svg.colorAttribute(3, rgbColor)).to.be.reverted
    })

    it("Should brighten by 3%", async function () {
        expectColorToEqual(await svg.brightenColor(black, 3, 0), 0x000000, "black->black")
        expectColorToEqual(await svg.brightenColor(black, 3, 1), 0x010101, "black->1")
        expectColorToEqual(await svg.brightenColor(one, 3, 0), 0x010101, "one->one")
        expectColorToEqual(await svg.brightenColor({ red: 0x21, green: 0x21, blue: 0x21, alpha: 0xFF }, 3, 0), 0x212121, "before threshold")
        expectColorToEqual(await svg.brightenColor({ red: 0x22, green: 0x22, blue: 0x22, alpha: 0xFF }, 3, 0), 0x232323, "after threshold")
        expectColorToEqual(await svg.brightenColor(white, 3, 0), 0xFFFFFF, "max limit")
        expectColorToEqual(await svg.brightenColor(white, 3, 1), 0xFFFFFF, "max limit + 1")
    })

    it("Should brighten by 100%", async function () {
        expectColorToEqual(await svg.brightenColor(black, 100, 2), 0x020202, "black->2")
        expectColorToEqual(await svg.brightenColor(one, 100, 0), 0x020202, "one->two")
        expectColorToEqual(await svg.brightenColor(white, 100, 0), 0xFFFFFF, "max limit")
        expectColorToEqual(await svg.brightenColor(white, 100, 1), 0xFFFFFF, "max limit + 1")
    })

    it("Should revert with RatioInvalid", async function() {
        await expect(svg.mixColors(black, white, 101, 100)).to.be.revertedWith("RatioInvalid")
    })

    it("Should mix colors matching black", async function () {
        expectColorToEqual(await svg.mixColors(black, white, 100, 100), 0x000000, "black/white 100")
        expectColorToEqual(await svg.mixColors(black, white, 100, 97), 0x000000, "black/white 97")
        expectColorToEqual(await svg.mixColors(black, white, 100, 103), 0x000000, "black/white 103")
    })

    it("Should mix colors matching midpoint", async function () {
        expectColorToEqual(await svg.mixColors(black, white, 50, 100), 0x7F7F7F, "black/white 50%")
    })

    it("Should mix colors matching white", async function () {
        expectColorToEqual(await svg.mixColors(black, white, 0, 100), 0xFFFFFF, "black/white 100")
        expectColorToEqual(await svg.mixColors(black, white, 0, 103), 0xFFFFFF, "black/white 103")
    })

    it("Should undermix white and overmix black", async function() {
        expectColorToEqual(await svg.mixColors(black, white, 99, 103), 0x020202, "black/white 103")
        expectColorToEqual(await svg.mixColors(black, white, 0, 97), 0xF7F7F7, "black/white 97")
    })

    var expectColorToEqual = (color: ColorStruct, expected: number, message: string = "") => {
        expect(color.red).to.equal(expected >> 16, `${message}: red fail`)
        expect(color.green).to.equal((expected & 0xFF00) >> 8, `${message}: green fail`)
        expect(color.blue).to.equal(expected & 0xFF, `${message}: blue fail`)
        // expect(color.alpha).to.equal(0xFF, `${message}: alpha fail`)
    }
})
