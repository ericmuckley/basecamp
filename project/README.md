# Publisher project

### Contract

The smart contract for this project is deployed to the [Base Sepolia](https://sepolia.basescan.org/) network.

### User interface

The user interface conssits of a javascript app written in the [SvelteKit](https://kit.svelte.dev/) framework.

To run the app locally, install dependencies in this directory with `npm i`. Then run the app using `npm run dev -- --open`.

Before pushing changes to git, perform code linting using `npx prettier . --write`.

To create a production version of the app, use `npm run build`.

### TODO

- Deployment scripts
  - [forge](https://www.alchemy.com/dapps/foundry-forge)
  - [hardhat](https://hardhat.org/hardhat-runner/docs/getting-started)
- IPFS integration using [Helia](https://github.com/ipfs/helia)
