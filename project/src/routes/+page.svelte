<script>

	import { decodeEventLog, hexToBigInt } from 'viem';

	import { fly } from 'svelte/transition';
	import Spinner from '$lib/Spinner.svelte';
	import FileUploader from '$lib/FileUploader.svelte';
	import { userAddress, networkId } from '$lib/stores.js';
    import Layout from './+layout.svelte';
    import TopNavBar from '../lib/TopNavBar.svelte';
    import { onMount } from 'svelte';

	import { SUPPORTED_NETWORK_ID, BLOCK_EXPLORER_URL, CONTRACT_ADDRESS, CONTRACT_METADATA } from '$lib/settings.js';


	let fileObject;
	let logs;
	let contractFunctions = null;

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
		{ field: 'lastModified', label: 'Last Modified Timestamp' },
		{ field: 'lastModifiedDate', label: 'Last Modified Date' },
		{ field: 'keccak256', label: 'Keccak256 Hash' },
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
				return x;
				let s = '';
				for (let i = 0; i < x.length; i++) {
					s += x[i].toString(16).padStart(2, '0');
				}
				return JSON.stringify(x.slice(0, 20)) + '...';
			}
		}
	];

	
	onMount(async () => {

		contractFunctions = getContractFunctions();
		console.log(contractFunctions);

		let res = await (await fetch("/api/logs")).json();
		logs = res.logs;

	});


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


</script>


{#if $networkId === SUPPORTED_NETWORK_ID}

	<div class="box shadow-xl shadow-indigo-600 my-10" in:fly={{ y: -80, duration: 800 }}>
		<h3>Contract {CONTRACT_ADDRESS}</h3>
		<p class="lead">
			<a href="{BLOCK_EXPLORER_URL}address/{CONTRACT_ADDRESS}" target="_blank">
				View on block explorer<i class="bi bi-box-arrow-right ml-2" />
			</a>
		</p>
	</div>


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
		</div>
	<!--
	{:else}
		<div in:fly={{ y: -80, duration: 800 }}>
			<FileUploader bind:fileObject />
		</div>
	-->	
	{/if}


	{#if contractFunctions}
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