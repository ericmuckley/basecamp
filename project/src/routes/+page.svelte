<script>
	import { readContract } from '@wagmi/core';
	import { fly } from 'svelte/transition';
	import UploadedFilePreview from '$lib/UploadedFilePreview.svelte';
	import FileUploader from '$lib/FileUploader.svelte';
	import LogsTable from '$lib/LogsTable.svelte';
	import SelectedItemPreview from '$lib/SelectedItemPreview.svelte';
	import TreeDiagram from '$lib/TreeDiagram.svelte';
	import { networkId, userAddress } from '$lib/stores.js';
	import { shortHash, NULL_ADDRESS } from '$lib/utils.js';
    import { onMount } from 'svelte';

	import { CHAIN_ID, BLOCK_EXPLORER_URL, CONTRACT_ADDRESS, CONTRACT_METADATA } from '$lib/contract_settings.js';

	let logSearch = "";
	let uploadedFile;
	let logs;
	let treeData;
	let selectedItem;
	let isLoading = true;
	let owners = null;


	// get all 'ItemCreated' contract event logs
	const getLogs = async () => {
		logs = null;
		let res = await (await fetch("/api/logs")).json();
		let rawLogs = res.logs.filter(x => x.eventName === "ItemCreated");
		for (let i = 0; i < rawLogs.length; i++) {
			let item = await readContract({
				address: CONTRACT_ADDRESS,
				abi: CONTRACT_METADATA.output.abi,
				functionName: 'getItemByHash',
				chainId: CHAIN_ID,
				args: [rawLogs[i].args._hash],
			});
			rawLogs[i].item = item;
			rawLogs[i].item.tokenId = Number(rawLogs[i].item.tokenId);
			rawLogs[i].item.blockCreated = Number(rawLogs[i].item.blockCreated);
    	};
		logs = [...rawLogs];
		console.log('logs', logs)
	};


	// organizes the log data into a tree structure for visualization
	const getTreeDataFromLogs = () => {
		let data = {
			"label": "Contract",
			"hash": NULL_ADDRESS,
			"children": getChildren(NULL_ADDRESS),
			"type": "contract",
		};
		treeData = {...data};
	};


	// recursive function that gets the children of a parent hash
	function getChildren(parentHash) {
		let result = [];
		for (let log of logs) {
			if (log.item.parentHash === parentHash) {
				log.item.transactionHash = log.transactionHash;
				log.item.timestamp = log.timestamp;
				log.item.parentHashTxn = log.transactionHash
				let child = {
					...log.item,
					"label": log.item.name,
					"children": getChildren(log.item.hash),
					"type": "item",
				};
				result.push(child);
			}
		}
		return result;
	}


	// get the owners of all contract tokens
	const getTokenOwners = async () => {
		// get current token counter
		let tokenCounter = await readContract({
			address: CONTRACT_ADDRESS,
			abi: CONTRACT_METADATA.output.abi,
			functionName: 'counter',
			chainId: CHAIN_ID,
		});
		// index all the owners and their tokens
		let tokenOwners = { byAddress: {}, byTokenId: {} };
		for (let i = 1; i < Number(tokenCounter); i++) {
			let owner = await readContract({
				address: CONTRACT_ADDRESS,
				abi: CONTRACT_METADATA.output.abi,
				functionName: 'ownerOf',
				chainId: CHAIN_ID,
				args: [i],
			});
			tokenOwners.byTokenId[i] = owner;
			if (tokenOwners.byAddress.hasOwnProperty(owner)) {
				tokenOwners.byAddress[owner].push(i);
			} else {
				tokenOwners.byAddress[owner] = [i];
			};
		};

		return tokenOwners
	};


	onMount(async () => {
		await getLogs();
		owners = await getTokenOwners();
		getTreeDataFromLogs();
		isLoading = false;
	});

</script>



{#if $networkId === CHAIN_ID}

	{#if isLoading}

		<div class="space-y-6">
			{#each Array(3) as _, _}
				<div class="p-2 w-full">
					<div class="animate-pulse">
						<div class="h-12 bg-slate-600 rounded-3xl"></div>
					</div>
				</div>
			{/each}
		</div>

	{:else}

		{#if treeData}
			<div
				class="mt-12 bg-slate-100 rounded-3xl p-6 shadow-xl mb-12 relative overflow-x-auto overflow-y-auto"
				in:fly={{ y: 100, duration: 800 }}
			>
				<h3>File version tree</h3>
				{#if selectedItem}
					{#key selectedItem.name}
						<SelectedItemPreview bind:selectedItem {owners} />
					{/key}
				{/if}
				<TreeDiagram data={treeData} bind:selectedItem />	
			</div>
		{/if}


		{#if uploadedFile}
			<div in:fly={{ y: -80, duration: 800 }}>
				<UploadedFilePreview bind:uploadedFile {logs} {owners} />
			</div>
		{:else}
			<div in:fly={{ y: 80, duration: 800 }}>
				<FileUploader bind:uploadedFile />
			</div>
		{/if}

		
		<div
			class="mt-12 bg-slate-100 rounded-3xl p-8 shadow-xl"
			in:fly={{ y: 100, duration: 800 }}
		>
			{#if logs}
				<div>
					<div class="flex justify-between mb-10">
						<h3 class="mb-0 whitespace-nowrap">
							Recently Published Items
							<span class="rounded-full bg-slate-500 text-white font-bold ml-2 px-3">
								{logs.length}
							</span>
						</h3>

						<div class="flex w-full px-12">
							<input
								type="text"
								placeholder="Search for published item..."
								class="text-sm focus:outline-0 w-full rounded-xl px-4 py-1 bg-transparent border-2 border-slate-300 focus:border-sky-600 hover:border-slate-400"
								bind:value={logSearch}
							/>
							{#if logSearch.length}
							<button
								class="-ml-8 text-sky-600 hover:sky-800"
								type="button"
								on:click={() => {logSearch = ""}}
							>
								<i class="bi bi-x-lg" />
							</button>
							{/if}
						</div>

						<button
							type="button"
							on:click={getLogs}
							class="text-2xl hovertext"
						>
							<i class="bi bi-arrow-clockwise" />
						</button>
					</div>

					<div class="w-full overflow-x-auto pb-3">
						<LogsTable {logs} filter={logSearch} {owners} />
					</div>
				</div>
			{:else}
				<div class="space-y-3">
					{#each Array(6) as _, _}
						<div class="p-2 w-full">
							<div class="animate-pulse">
								<div class="h-4 bg-slate-600 rounded-3xl"></div>
							</div>
						</div>
					{/each}				
				</div>
			{/if}
		</div>

	{/if}

{:else}

	<div class="box shadow-xl" in:fly={{ y: -80, duration: 800 }}>
		<h3>No wallet connection</h3>
		<p class="lead">
			Please connect your wallet and switch to the Base Goerli network to use this app.
		</p>
	</div>

{/if}

