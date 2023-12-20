<script>
	import '../app.css';

	/*
	Here we define all the logic for the ConnectWallet button.
	We then pass the handleConnectWallet function down as a prop into the
	child components. This allows us to instantiate the ConnectWallet
	button in different places in the app depending on the wallet
	connection status, and the mounting/unmounting of the button
	will not reset the wagmi client or ethereum clients.
	*/
	
	import TopNavBar from '$lib/TopNavBar.svelte';
	import { PUBLIC_WALLET_CONNECT_PROJECT_ID } from '$env/static/public'
	import { userAddress, networkId } from '$lib/stores.js';

	import {
		createConfig,
		configureChains,
		watchNetwork,
		watchAccount,
		getAccount,
		InjectedConnector,
		getNetwork,
	} from '@wagmi/core';
	import { mainnet, sepolia, base, baseGoerli, polygon, polygonMumbai } from '@wagmi/core/chains';
	import { CoinbaseWalletConnector } from '@wagmi/core/connectors/coinbaseWallet';
	import { WalletConnectConnector } from '@wagmi/core/connectors/walletConnect';
	//import { MetaMaskConnector } from '@wagmi/core/connectors/metaMask';
	import { EthereumClient, w3mProvider } from '@web3modal/ethereum';
	import { Web3Modal } from '@web3modal/html';

	// configure WalletConnect / Web3Modal
	const chains = [mainnet, sepolia, base, baseGoerli, polygon, polygonMumbai];
	const { publicClient } = configureChains(chains, [
		w3mProvider({ projectId: PUBLIC_WALLET_CONNECT_PROJECT_ID }),
	]);
	const wagmiConfig = createConfig({
		publicClient,
		autoConnect: true,
		connectors: [
			new InjectedConnector({}),
			new CoinbaseWalletConnector({}),
			new WalletConnectConnector({
				options: {
					projectId: PUBLIC_WALLET_CONNECT_PROJECT_ID,
					showQrModal: false,
				},
			}),
		],
	});
	const ethereumClient = new EthereumClient(wagmiConfig, chains);
	const web3modal = new Web3Modal({ projectId: PUBLIC_WALLET_CONNECT_PROJECT_ID }, ethereumClient);

	// when the Connect Wallet auth flow starts
	const handleConnectWallet = async () => {
		web3modal.openModal();
	};

	const handleWalletChange = () => {
		let account = getAccount();
		let network = getNetwork();
		//console.log('account', account)
		//console.log('network', network);
		$userAddress = (account && account.address) ? account.address : null;
		$networkId = (network && network.chain && network.chain.id) ? network.chain.id : null;
	};

	watchNetwork((x) => {
		handleWalletChange();
	});

	watchAccount((x) => {
		handleWalletChange();
	});

</script>

<TopNavBar {handleConnectWallet} />
<main>
	<slot />
</main>
