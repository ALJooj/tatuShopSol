const { expect } = require("chai")
const { ethers } = require("hardhat")

describe("TatuShop", function() {
    let owner
    let author
    let buyer
    let shop
    let tokenController

    beforeEach(async function(){
        [owner, author, buyer] = await ethers.getSigners()
        const MyToken = await ethers.getContractFactory("MyToken", owner)
        tokenController = await MyToken.deploy()
        await tokenController.deployed()

        const TatuShop = await ethers.getContractFactory("TatuShop", owner)
        shop = await TatuShop.deploy(tokenController.address)
        await shop.deployed()
    })
    
    it("sets owner ", async function(){
        const curOwner = await shop.owner()
        expect(curOwner).to.eq(owner.address)
        // console.log('address of curOwner:')
        // console.log(curOwner)
        // console.log('address of curOwner:')
        // console.log(await tokenController.owner())
        // console.log(owner)

        expect(curOwner).to.eq(await tokenController.owner())
    })

    it("set author  ", async function(){
        await shop.setAuthor(author.address, "testName", true)
        let u = await shop.approvalAuthor(author.address, "testName")
        expect(u).to.be.equal(true)

        await expect(shop.connect(author)
        .setAuthor(author.address, "testName", true)).to.be.reverted

        await expect(shop.connect(buyer)
        .setAuthor(author.address, "testName", true)).to.be.reverted
    })

    it("should create NFT ", async function(){
        await expect(shop.mintNFT("", "testName", author.address, 1000))
        .to.be.revertedWith("cant mint NFT for non author")

        await shop.setAuthor(author.address, "testName", true)
        // await tokenController.setApprovalForAll(shop.address, true)

        // let balance = await tokenController.balanceOf(author.address)
        await shop.mintNFT("", "testName", author.address, 1000)
        console.log(shop.address)
        // console.log(owner)
        // let d = await tokenController.ownerOf(0)
        // console.log(c)
        
        
        // let authorsName = await shop.authorsNFT(0)
        // console.log(authorsName)
        // await expect(authorsName).to.be.equal("testName")

    })
})