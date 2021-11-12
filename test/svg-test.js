const { expect } = require("chai")
const { ethers } = require("hardhat")

describe("SVG", function () {

    let svg
    let black = [0x0, 0x0, 0x0, 0xFF]
    let one = [0x1, 0x1, 0x1, 0xFF]
    let white = [0xFF, 0xFF, 0xFF, 0xFF]
    let zeroOneTwo = [0x0, 0x1, 0x2, 0xFF]
    let middleRandom = [152, 152, 150, 0xFF] // rgb even, results in 50%
    let brightestRandom = [100, 100, 102, 0xFF] // rgb even, results in 100%

    beforeEach(async () => {
        const SVG = await ethers.getContractFactory("SVGMock")
        svg = await SVG.deploy()
        await svg.deployed()
    })

    it("Should be floor color", async function() {
        expectColorToEqual(await svg.randomizeColors(black, white, black), 0x000000)
    })

    it("Should be middle color", async function() {
        expectColorToEqual(await svg.randomizeColors(black, white, middleRandom), 0x7F7F7F)
    })

    it("Should be ceiling color", async function() {
        expectColorToEqual(await svg.randomizeColors(black, white, brightestRandom), 0xFFFFFF)
    })

    it("Should not crash with tight color", async function() {
        expectColorToEqual(await svg.randomizeColors(black, one, [0x43, 0x11, 0xDA, 0xFF]), 0x000001)
    })
    
    it("Should generate proper svg element", async function () {
        var width = 180, height = 360
        expect(await svg.createSVG(width, height, "")).to.equal(`<svg viewBox='0 0 ${width} ${height}' xmlns='http://www.w3.org/2000/svg' version='1.1'></svg>`)
        expect(await svg.createSVG(width, height, "hello")).to.equal(`<svg viewBox='0 0 ${width} ${height}' xmlns='http://www.w3.org/2000/svg' version='1.1'>hello</svg>`)
    })
    
    it("Should generate proper path element", async function () {
        expect(await svg.createPath("", "")).to.equal("<path ></path>")
        expect(await svg.createPath("id='name'", "contents")).to.equal("<path id='name'>contents</path>")
    })
    
    it("Should generate fill svg color strings", async function () {
        expect(await svg.colorAttribute(zeroOneTwo, 0)).to.equal(" fill='rgb(0,1,2)'")
    })
    
    it("Should generate stroke svg color strings", async function () {
        expect(await svg.colorAttribute(zeroOneTwo, 1)).to.equal(" stroke='rgb(0,1,2)'")
    })
    
    it("Should generate bare svg color strings", async function () {
        expect(await svg.colorAttribute(zeroOneTwo, 2)).to.equal("rgb(0,1,2)")
    })

    it("Should correctly convert packed colors", async function() {
        expectColorToEqual(await svg.fromPackedColor(0x000000), 0x000000, "black")
        expectColorToEqual(await svg.fromPackedColor(0x010101), 0x010101, "one")
        expectColorToEqual(await svg.fromPackedColor(0xFFFFFF), 0xFFFFFF, "white")
    })
    
    it("Should generate svg color type error", async function () {
        await expect(svg.colorAttribute(zeroOneTwo, 3)).to.be.reverted
    })

    it("Should brighten by 3%", async function () {
        expectColorToEqual(await svg.brightenColor(black, 3, 0), 0x000000, "black->black")
        expectColorToEqual(await svg.brightenColor(black, 3, 1), 0x010101, "black->1")
        expectColorToEqual(await svg.brightenColor(one, 3, 0), 0x010101, "one->one")
        expectColorToEqual(await svg.brightenColor([0x21, 0x21, 0x21, 0xFF], 3, 0), 0x212121, "before threshold")
        expectColorToEqual(await svg.brightenColor([0x22, 0x22, 0x22, 0xFF], 3, 0), 0x232323, "after threshold")
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

    var expectColorToEqual = (color, expected, message) => {
        expect(color[0]).to.equal(expected >> 16, `${message}: red fail`)
        expect(color[1]).to.equal((expected & 0xFF00) >> 8, `${message}: green fail`)
        expect(color[2]).to.equal(expected & 0xFF, `${message}: blue fail`)
        // expect(color[3]).to.equal(0xFF, `${message}: alpha fail`)
    }
})
