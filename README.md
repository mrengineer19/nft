# NFT creation and render on opensea

## Blockchain

Make .env file in root directory, copy variables from .env.example and set according to your requirement.

Run following commands :

```
truffle compile
```

```
truffle migrate --network rinkeby
```

You need to deploy contract on rinkeby network in order to render it on Opensea. If you don't need Opensea rendering feel free to deploy on any network including local.

To test the contract run

```
truffle test
```

For local development you need to install ganache, please follow this URL for more information 
[Ganache cli](https://www.npmjs.com/package/ganache-cli)

Make sure you've [Metamask](https://metamask.io/download) installed and running on browser

## Front end setup
```
npm install
```

### Compiles and hot-reloads for development
```
npm run serve
```

### Compiles and minifies for production
```
npm run build
```

### Customize configuration
See [Configuration Reference](https://cli.vuejs.org/config/).
