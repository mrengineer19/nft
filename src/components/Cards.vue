<template>
  <b-container>
    <div v-if="account" class="mt-3">
      <b-form>
        <b-form-group id="input-group-2" class="mb-3" label="Enter NFT name" label-for="input-2">
          <b-form-input
            id="input-2"
            v-model="form.name"
            placeholder="Enter name"
            required
          ></b-form-input>
        </b-form-group>

        <b-form-group id="input-group-2" class="mb-3" label="Enter NFT Description" label-for="input-2">
          <b-form-textarea
            id="textarea"
            v-model="form.description"
            placeholder="Enter Description..."
            rows="3"
            max-rows="6"
          ></b-form-textarea>
        </b-form-group>

        <b-form-group id="input-group-2" class="mb-3" label="Select Image" label-for="input-2">
          <b-form-file
            :ref="'file'"
            @change="handleFile"
            placeholder="Choose a file or drop it here..."
            drop-placeholder="Drop file here..."
          ></b-form-file>
        </b-form-group>

        <b-button type="submit" @click.prevent="createNFT()" variant="primary">Submit</b-button>
      </b-form>
      
        <b-alert show variant="danger" v-if="error" class="mt-4" v-html="error"></b-alert>
        
        <b-alert show variant="success" v-if="success" class="mt-4" v-html="success"></b-alert>
      
    </div>
    <div v-else>
      <h5>Please install metamask wallet to use this site</h5>
    </div>

    <div v-if="allNFT.length > 0" class="row">
      <div class="col-md-3" v-for="(nft,key) in allNFT" :key="key">
        <b-card
          :title="nft.name"
          :img-src="nft.image"
          img-alt="Image"
          img-top
          tag="article"
          style="max-width: 20rem;"
          class="mb-2"
        >
          <b-card-text>
            {{nft.description}}
          </b-card-text>

          <b-button target="_blank" :href="process.env.OPEN_SEA + contract.options.address + '/' + nft.id " variant="primary">Go to opensea</b-button>
        </b-card>
    </div>
    </div>
    
  </b-container>
</template>

<script>
//import axios from "axios";
const { create } = require('ipfs-http-client')
const ipfs = create({host:process.env.INFURA_HOST, port:5001, protocol:'https'})
import MintNFT from '../../build/contracts/MintNFT.json'

export default {
  props: ['account', 'web3'],
  data() {
    return {
      allNFT: [],
      error: null,
      success: null,
      contract: null,
      form: {
        name: null,
        description: null,
        image: null,
      }
    };
  },
  async mounted() {
      const networkId = await this.web3.eth.net.getId()
      const networkData = MintNFT.networks[networkId]
      if (typeof networkData !== 'undefined') {
        this.contract = new this.web3.eth.Contract(MintNFT.abi, networkData.address)
      } else {
          this.success = null
          this.error = 'Smart contract is not hosted on this network.'
      }

      let $this = this

      this.contract.events.Created(function(error, event) { 
        if (!error) {
          $this.makeNft(event.returnValues)
        }
      })

      this.getNFTs()
  },
  methods:{
      async makeNft(nft) {
          const response = await fetch(nft.tokenURI);
          const data = await response.json();
          nft.image = data.image
          this.allNFT.push(nft)
      },
      async getNFTs() {
        let count = await this.contract.methods.tokenCount().call()
        
        for (let i = 1; i <= count; i++) {
          const nft = await this.contract.methods.tokens(i).call()
          this.makeNft(nft)
        }
      },
      async createNFT () {
        let tokenURI = null
        if (this.form.image) {
          this.error = null
          this.success = 'Uploading file to IPFS.....'
          const result = await ipfs.add(this.form.image)
          if (result.path) {
            this.form.image = process.env.IPFS_URL + result.path
          } else {
            this.success = null
            this.error = 'File not uploaded to IPFS, something went wrong. Please try again.'
            return false
          }
          var buf = Buffer.from(JSON.stringify(this.form));

          const jsonFile = await ipfs.add(buf)
          if (jsonFile.path) {
              this.error = null
              this.success = 'File uploaded to IPFS, now uploading data to blockchain.'
              tokenURI = process.env.IPFS_URL + jsonFile.path
            } else {
              this.success = null
              this.error = 'JSON file not uploaded to IPFS, something went wrong. Please try again.'
              return false
            }

            if (tokenURI && this.account && this.contract) {
                this.contract.methods.createToken(this.form.name, this.form.description, tokenURI).send({ from : this.account}).then(response => {
                  this.success = 'NFT successfully created. Your transaction hash is : '+ response.transactionHash
                }).catch(error => {
                  this.success = null
                  this.error = error.message
                })
             }
        } else {
            this.success = null
            this.error = 'Validation error.'
        }
      },
      async handleFile (file) {
          const reader = new FileReader();
          if (typeof file !== 'undefined') {
            reader.readAsArrayBuffer(file.target.files[0]);
            reader.onloadend = async () => {
              this.form.image = await Buffer.from(reader.result);
            };
          } 
      },
  }
};
</script>