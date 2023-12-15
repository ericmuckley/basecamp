<script>
	import { readContract } from '@wagmi/core';
	import { fly } from 'svelte/transition';
	import EventLogPreview from '$lib/EventLogPreview.svelte';
	import UploadedFilePreview from '$lib/UploadedFilePreview.svelte';
	import FileUploader from '$lib/FileUploader.svelte';
	import { networkId } from '$lib/stores.js';
    import { onMount } from 'svelte';

	import { CHAIN_ID, BLOCK_EXPLORER_URL, CONTRACT_ADDRESS, CONTRACT_METADATA } from '$lib/contract_settings.js';

	//import { Helia } from 'helia';

	//import { createHelia } from 'helia'

	//const ipfs = new Helia({ url: 'http://127.0.0.1:8080' });


	let logSearch = "";
	let uploadedFile;
	let logs;
	let contractFunctions = null;

	// TODO implement function for filtering logs
	// TODO implement visualization of tokens by address
	// TODO link published items to tokens

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
			rawLogs[i].item.blockCreated = Number(rawLogs[i].item.blockCreated);
    	};
		logs = [...rawLogs];
		console.log('logs', logs)
	};


	const getTokenOwners = async () => {
		// get current token counter
		let tokenCounter = await readContract({
			address: CONTRACT_ADDRESS,
			abi: CONTRACT_METADATA.output.abi,
			functionName: 'counter',
			chainId: CHAIN_ID,
		});
		// index all the owners and their tokens
		let owners = {}
		for (let i = 1; i < Number(tokenCounter); i++) {
			let owner = await readContract({
				address: CONTRACT_ADDRESS,
				abi: CONTRACT_METADATA.output.abi,
				functionName: 'ownerOf',
				chainId: CHAIN_ID,
				args: [i],
			});
			if (owners.hasOwnProperty(owner)) {
				owners[owner].push(i);
			} else {
				owners[owner] = [i];
			};
		};
		console.log(owners);

	};


	onMount(async () => {

		getLogs();
		getTokenOwners();
		//const helia = await createHelia();

		//contractFunctions = getContractFunctions();
		//console.log(contractFunctions);

	});

	/*
	// Function to pin a file to the local IPFS node
	const pinFileToIPFS = async (fileInput) => {
		try {
			// Create a FormData object and append the file to it
			const formData = new FormData();
			formData.append('file', uploadedFile.file);

			// Upload the file to IPFS using the add method
			const uploadResponse = await ipfs.add(formData);

			// Get the CID (Content Identifier) of the uploaded file
			const cid = uploadResponse.cid.toString();

			// Pin the file to the local IPFS node
			await ipfs.pin.add(cid);

			console.log(`File pinned successfully. CID: ${cid}`);
		} catch (error) {
			console.error('Error pinning file to IPFS:', error);
		};
	};
	*/


</script>



{#if $networkId === CHAIN_ID}


	<div class="grid grid-cols-3 gap-12">

		<div class="col-span-2">

			{#if uploadedFile}
				<div in:fly={{ y: -80, duration: 800 }}>
					<UploadedFilePreview bind:uploadedFile {getLogs} />
				</div>
			{:else}
				<div in:fly={{ y: -80, duration: 800 }}>
					<FileUploader bind:uploadedFile />
				</div>
			{/if}


			{#if contractFunctions && 0}
				<div class="box shadow-xl shadow-indigo-600 my-10" in:fly={{ y: -80, duration: 800 }}>
					<h3>Contract functions</h3>
					<pre class="font-mono text-sm text-slate-600 bg-slate-100 rounded-2xl p-8">{JSON.stringify(contractFunctions, null, 4)}</pre>
				</div>
			{/if}

		</div>


		<div>
			<div class="bg-slate-100 rounded-3xl p-8 shadow-xl" in:fly={{ y: -80, duration: 800 }}>
				<div class="flex justify-between space-x-4">
					<h3>Recently published items</h3>
					<button
						type="button"
						on:click={getLogs}
						class="text-2xl hovertext"
					>
						<i class="bi bi-arrow-clockwise" />
					</button>
				</div>

				<div class="flex mt-3">
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

				

				<div class="space-y-4 mt-6">
					{#if logs && logs.length}
						{#each logs as log}
							{#if log.item.name.toLowerCase().includes(logSearch.toLowerCase()) }
							<EventLogPreview {log} {logs} />
							{/if}
						{/each}
					{:else if logs && logs.length === 0 && logSearch === ""}
						<p class="lead mt-6">
							No contract events have been logged.
						</p>
					{:else}
						{#each Array(6) as _, i}
							<div class="border border-slate-200 shadow-xl rounded-3xl p-8 max-w-sm w-full mx-auto">
								<div class="animate-pulse flex space-x-4">
								<div class="flex-1 space-y-6 py-1">
									<div class="h-2 bg-slate-600 rounded"></div>
									<div class="h-6 bg-slate-600 rounded"></div>
									<div class="space-y-3">
									<div class="grid grid-cols-3 gap-4">
										<div class="h-2 bg-slate-600 rounded col-span-2"></div>
										<div class="h-2 bg-slate-600 rounded col-span-1"></div>
									</div>
									<div class="h-2 bg-slate-600 rounded"></div>
									</div>
								</div>
								</div>
							</div>
						{/each}
					{/if}
				</div>
			</div>
			
		</div>

	</div>


{:else}

	<div class="box shadow-xl" in:fly={{ y: -80, duration: 800 }}>
		<h3>No wallet connection</h3>
		<p class="lead">
			Please connect your wallet and switch to the Base Goerli network to use this app.
		</p>
	</div>

{/if}
