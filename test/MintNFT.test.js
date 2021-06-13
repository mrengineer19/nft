const { assert } = require('chai')

const nft = artifacts.require('./MintNFT.sol')

require('chai')
.use(require('chai-as-promised'))
.should()

contract('nft', (accounts) => {
    let contract
    describe('contract deployment', async() => {
        it('deployed successfully', async() => {
            contract = await nft.deployed()
            assert.notEqual(contract.address, '')
            assert.notEqual(contract.address, 0x0)
            assert.notEqual(contract.address, null)
            assert.notEqual(contract.address, undefined)
        })

        it('initial values', async() => {
            const name = await contract.name()
            const symbol = await contract.symbol()
            assert.equal(name, 'Master NFT')
            assert.equal(symbol, 'MNFT')
        })
    })

    describe('create token', async() => {
        it('created', async() => {
            const created = await contract.createToken('Test nft', 'description for test nft', 'tokenURI')
            const totalSupply = await contract.totalSupply()
            const event = created.logs[0].args
            assert.equal(totalSupply, 1)
            assert.equal(event.to, accounts[0])
        })
    })

    describe('listing', async() => {
        it('get all tokens', async() => {
            await contract.createToken('1st nft', '1st nft description', 'tokenURI1')
            await contract.createToken('2st nft', '2st nft description', 'tokenURI2')
            await contract.createToken('3st nft', '3st nft description', 'tokenURI3')
            await contract.createToken('4st nft', '4st nft description', 'tokenURI4')
            await contract.createToken('5st nft', '5st nft description', 'tokenURI5')

            const totalSupply = await contract.totalSupply()
            let tokens, result = []
            
            for(let i = 1; i <= totalSupply; i++) {
                tokens = await contract.tokens(i)
                result.push(tokens)
            }

            assert.notEqual(result.length, 0)
            //console.log(result)
        })
    })
})