<script>
	import { writeContract, readContract, getNetwork, switchNetwork } from '@wagmi/core';
	import { onMount } from 'svelte';
	import { fly } from 'svelte/transition';
	import Loading from '$lib/components/Loading.svelte';

	let functions = [];
	let isLoading = true;
	let showModal = false;
	let selectedUser = null;
	let selectedAddressField = null;

	$: selectedUser, setAddressField();

	onMount(() => {
		getContractFunctions();
	});

	// get the contract instance and its functions
	const getContractFunctions = async () => {
		isLoading = true;
		functions = [...contract.abi].filter((x) => x.type === 'function');
		for (let f of functions) {
			f.waiting = false;
			f.result = null;
			f.error = false;
			for (let i of f.inputs) {
				i.value = '';
			}
		}
		isLoading = false;
	};

	// make a call to the smart contract function
	const callContractFunction = async (functionName) => {
		const func = functions.find((f) => f.name === functionName);
		func.result = null;
		func.waiting = true;
		func.error = false;
		functions = [...functions];

		let args = func.inputs.map((x) => x.value);

		const payload = {
			address: contract.address,
			abi: contract.abi,
			functionName: functionName,
			chainId: contract.chain_id,
			args: args,
		};

		try {
			if (func.constant || func.stateMutability === 'view') {
				func.result = await readContract(payload);
			} else {
				/*
				if (contract.owner !== $currentUser.ethereum_address) {
					alert('You must be the owner of this contract to perform this action');
					func.waiting = false;
					return;
				}
				*/

				const { chain } = getNetwork();
				if (chain.id !== contract.chain_id) {
					await switchNetwork({
						chainId: contract.chain_id,
					});
					func.waiting = false;
					return;
				}

				let result = await writeContract(payload);
				func.result = `
					Submitted!
					<a href="${contract.block_explorer_url}/tx/${result.hash}" target="_blank">
						&nbsp;&nbsp;View on block explorer
						<i class="bi bi-box-arrow-right ml-1"></i>
					</a>
				`;
			}
		} catch (e) {
			console.log(e);
			func.error = true;
			func.result = e.message;
		}

		functions = [...functions];
		func.waiting = false;
	};

	// set the selected address field value to the selected user's address
	const setAddressField = () => {
		if (selectedUser && selectedAddressField) {
			selectedAddressField.value = selectedUser.ethereum_address;
			functions = [...functions];
		}
		selectedUser = null;
		selectedAddressField = null;
	};
</script>

{#if isLoading || !contract}
	<Loading text="Loading token details..." />
{:else}

	<div class="grid grid-cols-4 mt-16">
		<div class="col-span-1">
			<div class="sticky top-16">
				<h3 class="mb-2">Functions</h3>
				{#each functions as func}
					<a href={`#${func.name}`} class="w-min text-sm block py-0.5 hover:font-bold">
						{func.name}
					</a>
				{/each}
			</div>
		</div>

		<div class="col-span-3">
			<div class="space-y-10">
				{#each functions as func}
					<div class="box bg-dark1">
						<div id={func.name} class="relative -top-[110px]" />
						<div class="">
							{#if func.inputs.length && !func.inputs.every((x) => x.value.length)}
								<h3 class="dark:text-lightgray">{func.name}</h3>
								<div class="text-xs text-gray dark:text-gray">
									Populate the fields below to execute this function
								</div>
							{:else}
								<div class="flex justify-between text-xl">
									<button
										type="button"
										class="primary-btn"
										on:click={() => {
											callContractFunction(func.name);
										}}
										disabled={func.waiting}
									>
										<i class="bi bi-play-circle-fill mr-2" />{func.name}
									</button>

									<div>
										{#if func.result}
											<button
												class="hovertext"
												on:click={() => {
													navigator.clipboard.writeText(func.result);
													func.resultCopied = true;
												}}
											>
												<i
													class="bi bi-{func.resultCopied
														? 'check-circle-fill'
														: 'files'} mr-1"
												/>Copy result
											</button>
										{/if}
									</div>
								</div>
							{/if}
						</div>
						{#each func.inputs as input, i}
							<div class="flex mt-3">
								<div class="w-full">
                                    <input
                                        placeholder={`Enter ${input.name} (${input.type})...`}
                                        type="text"
                                        bind:value={input.value}
                                    >
								</div>
								{#if input.type === 'address'}
									<button
										class="pt-6 text-3xl ml-4 hovertext"
										type="button"
										on:click={() => {
											selectedAddressField = input;
											showModal = true;
										}}
									>
										<i class="bi bi-search" />
									</button>
								{/if}
							</div>
						{/each}

						{#if func.waiting}
							<div class="mt-3" in:fly={{ y: -50, duration: 500 }}>
								<Loading />
							</div>
						{:else if func.result !== null}
							<div class="" in:fly={{ x: 200, duration: 500 }}>
								<div
									class="overflow-x-auto text-darkgray dark:text-extralightgray text-lg font-bold py-4 px-3"
								>
									{#if func.error}
										<pre class="text-darkgray">{func.result}</pre>
									{:else}
										{@html func.result}
									{/if}
								</div>
							</div>
						{/if}
					</div>
				{/each}
			</div>
		</div>
	</div>
{/if}