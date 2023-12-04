<script>
	import { fly } from 'svelte/transition';
	import Spinner from '$lib/Spinner.svelte';
	import FileUploader from '$lib/FileUploader.svelte';
	import { userAddress, networkId } from '$lib/stores.js';
    import Layout from './+layout.svelte';
    import TopNavBar from '../lib/TopNavBar.svelte';

	const SUPPORTED_NETWORK_ID = 84531; // for Base Goerli chain
	let fileObject;

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

</script>


{#if $networkId !== SUPPORTED_NETWORK_ID}

	<div class="box shadow-xl shadow-indigo-600" in:fly={{ y: -80, duration: 800 }}>
		<h3>Unsupported Network</h3>
		<p class="lead">
			Please switch to the Base Goerli network to use this app.
		</p>
	</div>

{:else if fileObject}
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
{:else}
	<div in:fly={{ y: -80, duration: 800 }}>
		<FileUploader bind:fileObject />
	</div>
{/if}
