<script>
	import { readContract } from '@wagmi/core';
	import { fly } from 'svelte/transition';
	import UploadedFilePreview from '$lib/UploadedFilePreview.svelte';
	import FileUploader from '$lib/FileUploader.svelte';
	import LogsTable from '$lib/LogsTable.svelte';
	import { networkId } from '$lib/stores.js';
    import { onMount } from 'svelte';

	import { CHAIN_ID, BLOCK_EXPLORER_URL, CONTRACT_ADDRESS, CONTRACT_METADATA } from '$lib/contract_settings.js';


	let logSearch = "";
	let uploadedFile;
	let logs;
	let contractFunctions = null;

	//$: logSearch, filterLogs();

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

	});



	const handleTransfer = async () => {
        errorMessage = null;
        progress.set(0.0);
        progress.set(0.1);
        let parentHash = (selectedVersioning == 'versioning-root' ) ? toHex(pad(0)) : parentHashInput;
        const { chain } = getNetwork();
        try {
            const result =  await writeContract({
                address: CONTRACT_ADDRESS,
                abi: CONTRACT_METADATA.output.abi,
                functionName: 'safeTransferFrom',
                chainId: CHAIN_ID,
                args: [fromAddress, toAddress, tokenId],
            });
            progress.set(0.9);
            const txnData = await waitForTransaction({
                hash: result.hash,
                chain,
            });
            progress.set(0.0)
            uploadedFile = null;
        } catch (error) {
            progress.set(0.0);
            console.log("ERROR:")
            console.log(error.message);
			errorMessage = error.message;
        };
        getLogs();
    };



</script>



{#if $networkId === CHAIN_ID}


	<div>

		{#if uploadedFile}
			<div in:fly={{ y: -80, duration: 800 }}>
				<UploadedFilePreview bind:uploadedFile {getLogs} />
			</div>
		{:else}
			<div in:fly={{ y: 80, duration: 800 }}>
				<FileUploader bind:uploadedFile />
			</div>
		{/if}

	</div>


	
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
					<LogsTable {logs} filter={logSearch} />
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

	

	


{:else}

	<div class="box shadow-xl" in:fly={{ y: -80, duration: 800 }}>
		<h3>No wallet connection</h3>
		<p class="lead">
			Please connect your wallet and switch to the Base Goerli network to use this app.
		</p>
	</div>

{/if}
