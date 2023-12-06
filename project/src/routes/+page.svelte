<script>

	import { decodeEventLog, hexToBigInt } from 'viem';
	import { readContract, writeContract } from '@wagmi/core';

	import { fly } from 'svelte/transition';
	import Spinner from '$lib/Spinner.svelte';
	import FileUploader from '$lib/FileUploader.svelte';
	import { userAddress, networkId } from '$lib/stores.js';
    import Layout from './+layout.svelte';
    import TopNavBar from '../lib/TopNavBar.svelte';
    import { onMount } from 'svelte';

	import { CHAIN_ID, BLOCK_EXPLORER_URL, CONTRACT_ADDRESS, CONTRACT_METADATA } from '$lib/settings.js';


	let fileObject;
	let logs;
	let contractFunctions = null;
	let publishedItems;

	const FIELDS = [
		{ field: 'name', label: 'Name' },
		{ field: 'type', label: 'Type' },
		{
			field: 'size',
			label: 'Size',
			format: (x) => {
				return `${x / 1000} KB`;
			}
		},
		//{ field: 'lastModified', label: 'Last Modified Timestamp' },
		{ field: 'lastModifiedDate', label: 'Last Modified' },
		//{ field: 'keccak256', label: 'Keccak256 Hash' },
		{
			field: 'bytesArrayLength',
			label: 'Bytes Array Length',
			format: (x) => {
				return x.toLocaleString();
			}
		},
		{
			field: 'bytesArray',
			label: 'Bytes Array',
			format: (x) => {
				return `${x.slice(0, 8)}.......${x.slice(x.length - 8, x.length)}`;
			}
		}
	];

	
	onMount(async () => {

		//contractFunctions = getContractFunctions();
		//console.log(contractFunctions);

		let res = await (await fetch("/api/logs")).json();
		let rawLogs = res.logs;

		// retrieve full published items from chain storage
		for (let i = 0; i < rawLogs.length; i++) {
			let item = await getPublishedItem(rawLogs[i].args._hash);
			rawLogs[i].item = item;
			rawLogs[i].item.blockCreated = Number(rawLogs[i].item.blockCreated);
    	};
		logs = [...rawLogs];

	});



	const getPublishedItem = async (itemHash) => {
		return await readContract({
			address: CONTRACT_ADDRESS,
			abi: CONTRACT_METADATA.output.abi,
			functionName: 'getItemByHash',
			chainId: CHAIN_ID,
			args: [itemHash],
		});
	};

	/*
	const getContractFunctions = () => {
		let functions = [...CONTRACT_METADATA.output.abi].filter((x) => x.type === 'function');
		console.log(functions)
		for (let f of functions) {
			f.waiting = false;
			f.result = null;
			for (let i of f.inputs) {
				i.value = '';
			};
		};
		console.log(functions);
		return functions;
	};

	*/

	const shortHash = (s, n = 16) => {
		return `${s.slice(0, n)}...${s.slice(s.length - n, s.length)}`;
	};

	const handlePublish = async () => {

		console.log("SUBMITING")
		console.log(typeof fileObject.bytesArray,typeof fileObject.bytesArray[0])
		console.log(fileObject.bytesArray)
		const result =  await writeContract({
			address: CONTRACT_ADDRESS,
			abi: CONTRACT_METADATA.output.abi,
			functionName: 'createItem',
			chainId: CHAIN_ID,
			args: ['name', 'description', fileObject.bytesArray],
		});

		let msg = `
			Submitted!
			<a href="${BLOCK_EXPLORER_URL}/tx/${result.hash}" target="_blank">
				&nbsp;&nbsp;View on block explorer
				<i class="bi bi-box-arrow-right ml-1"></i>
			</a>
		`;
		console.log(result);
		console.log(msg);

		return msg;
	}

</script>


{#if $networkId === CHAIN_ID}


	{#if logs}
		<div class="box shadow-xl shadow-indigo-600 my-10" in:fly={{ y: -80, duration: 800 }}>
			<h3>Recently published items</h3>
			<p class="lead">
				<a href="{BLOCK_EXPLORER_URL}address/{CONTRACT_ADDRESS}" target="_blank">
					View contract on block explorer<i class="bi bi-box-arrow-right ml-2" />
				</a>
			</p>			
			<div class="space-y-4 mt-3">
				{#each logs as log}
					<div class="rounded-2xl bg-slate-200 text-slate-600 px-6 py-6">
						<p class="font-bold text-xl">{log.item.name}</p>
						<div class="text-xs">
							{log.timestamp}
						</div>
						<div>
							Published by
							<a
								href="{BLOCK_EXPLORER_URL}/address/{log.item.creator}"
								target="_blank"
							>
								{log.item.creator.slice(0, 6)}
								<i class="bi bi-box-arrow-right ml-1" />
							</a>						
						</div>
						<div>
							<a
								href="{BLOCK_EXPLORER_URL}/tx/{log.transactionHash}"
								target="_blank"
							>
								View transaction on block explorer
								<i class="bi bi-box-arrow-right ml-1" />
							</a>
						</div>

						<div class="text-lg italic my-1">
							{log.item.description}
						</div>
						<div class="text-sm">
							keccak256: {shortHash(log.item.hash)}
						</div>

					</div>
				{/each}
				<div></div>
			</div>
		</div>
	{/if}


	{#if fileObject}
		<div class="box shadow-xl shadow-indigo-600" in:fly={{ y: -80, duration: 800 }}>
			<div class="flex justify-between">
				<h3>{fileObject.name}</h3>
				<div>
					<button
						type="button"
						class="text-xl text-indigo-500 hover:text-indigo-800"
						on:click={() => {
							fileObject = null;
						}}
					>
						<i class="bi bi-x-lg" />
					</button>
				</div>
			</div>
			<div class="mt-6">
				<table class="border-spacing-y-4">
					{#each FIELDS as field}
						<tr class="text-slate-600">
							<td class="font-bold whitespace-nowrap pr-6">{field.label}</td>
							<td>
								{#if field.format}
									{field.format(fileObject[field.field])}
								{:else}
									{fileObject[field.field]}
								{/if}
							</td>
						</tr>
					{/each}
				</table>
			</div>
			<button
				type="button"
				class="mt-8 w-full rounded-full px-6 py-1 text-lg bg-indigo-600 hover:bg-indigo-800 text-white"
				on:click={handlePublish}
			>
				<i class="bi bi-file-earmark-lock-fill mr-2"/>Publish
			</button>
		</div>
	
	{:else}
		<div in:fly={{ y: -80, duration: 800 }}>
			<FileUploader bind:fileObject />
		</div>
	
	{/if}


	{#if contractFunctions && 0}
		<div class="box shadow-xl shadow-indigo-600 my-10" in:fly={{ y: -80, duration: 800 }}>
			<h3>Contract functions</h3>
			<pre class="font-mono text-sm text-slate-600 bg-slate-100 rounded-2xl p-8">{JSON.stringify(contractFunctions, null, 4)}</pre>
		</div>
	{/if}



{:else}

	<div class="box shadow-xl shadow-indigo-600" in:fly={{ y: -80, duration: 800 }}>
		<h3>Unsupported Network</h3>
		<p class="lead">
			Please switch to the Base Goerli network to use this app.
		</p>
	</div>

{/if}




{#if logs}
	<div class="my-10">
		<pre class="font-mono text-sm text-slate-600 bg-slate-100 rounded-2xl p-8">{JSON.stringify(logs, null, 4)}</pre>
	</div>
{:else}
	<h3>No contract logs found</h3>
{/if}