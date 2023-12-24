<script>
    import { fly, slide } from 'svelte/transition';
    import { tweened } from 'svelte/motion';
    import { cubicOut } from 'svelte/easing';
    import CopyButton from '$lib/CopyButton.svelte';
    import { shortHash } from '$lib/utils.js';
    import { userAddress } from '$lib/stores.js'
    import { writeContract, waitForTransaction, getNetwork } from '@wagmi/core';
	import { CHAIN_ID, BLOCK_EXPLORER_URL, CONTRACT_ADDRESS, CONTRACT_METADATA } from '$lib/contract_settings.js';

    export let selectedItem;
    export let owners;
    let showTransferMenu = false;
	let errorMessage;
    let recipientAddress = "";
    let isTransferring = false;

    const progress = tweened(0.0, {duration: 6000, easing: cubicOut});

	const handleTransfer = async () => {
        isTransferring = true;
        errorMessage = null;
        progress.set(0.0);
        progress.set(0.1);
        const { chain } = getNetwork();
        try {
            const result =  await writeContract({
                address: CONTRACT_ADDRESS,
                abi: CONTRACT_METADATA.output.abi,
                functionName: 'safeTransferFrom',
                chainId: CHAIN_ID,
                args: [$userAddress, recipientAddress, selectedItem.tokenId],
            });
            progress.set(0.9);
            const txnData = await waitForTransaction({
                hash: result.hash,
                chain,
            });
            location.reload();
            progress.set(0.0)
        } catch (error) {
            //progress.set(0.0);
            console.log("ERROR:")
            console.log(error.message);
            errorMessage = error.message;
        };
    };

</script>



<div
    in:fly={{ y:100, duration:400 }}
    class="bg-slate-200 bg-opacity-90 rounded-tr-3xl rounded-bl-3xl absolute top-0 right-0 px-5 py-4 w-96 shadow-lg"
>
    <div class="flex justify-between space-x-6 mb-2">
        <div class="font-bold text-slate-600">
            {#if selectedItem.type === "contract"}
                Contract
            {:else}
                {selectedItem.name}
            {/if}
        </div>
        <button type="button" class="hovertext" on:click={() => {selectedItem = null}}>
            <i class="bi bi-x-lg" />
        </button>
    </div>
    <div class="text-slate-500 text-xs max-w-24">
        {#if selectedItem.type === "contract"}
            <div>
                <span class="mr-2">
                    <CopyButton text={CONTRACT_ADDRESS} />
                </span>
                <a
                    href="{BLOCK_EXPLORER_URL}address/{CONTRACT_ADDRESS}"
                    target="_blank"
                    class="hovertext"
                >
                    {shortHash(CONTRACT_ADDRESS, 6)}
                    <i class="bi bi-box-arrow-up-right ml-1" />
                </a>
            </div>
        {:else}
            <div>
                <table>
                    <tr>
                        <th class="pr-3">Token ID</th>
                        <td>
                            {selectedItem.tokenId}
                        </td>
                    </tr>
                    <tr>
                        <th class="pr-3">Created</th>
                        <td>
                            {selectedItem.timestamp}
                        </td>
                    </tr>
                    <tr>
                        <th class="pr-3">Creator <CopyButton text={selectedItem.creator}/></th>
                        <td>
                            <a href="{BLOCK_EXPLORER_URL}/address/{selectedItem.creator}" target="_blank">
                                {shortHash(selectedItem.creator, 6)}
                                <i class="bi bi-box-arrow-up-right" />
                            </a>
                        </td>
                    </tr>	
                    <tr>
                        <th class="pr-3">Owner <CopyButton text={owners.byTokenId[selectedItem.tokenId]}/></th>
                        <td>
                            <a href="{BLOCK_EXPLORER_URL}/address/{owners.byTokenId[selectedItem.tokenId]}" target="_blank">
                                {shortHash(owners.byTokenId[selectedItem.tokenId], 6)}
                                <i class="bi bi-box-arrow-up-right" />
                            </a>
                        </td>
                    </tr>              
                    <tr>
                        <th class="pr-3">File hash <CopyButton text={selectedItem.hash}/></th>
                        <td>
                            <a href="{BLOCK_EXPLORER_URL}tx/{selectedItem.transactionHash}" target="_blank">
                                {shortHash(selectedItem.hash, 6)}
                                <i class="bi bi-box-arrow-up-right" />
                            </a>
                        </td>
                    </tr>
                    <tr>
                        <th class="pr-3">Description</th>
                        <td class="!max-w-12">
                            {selectedItem.description}
                        </td>
                    </tr>
                </table>
            </div>


            {#if owners.byTokenId[selectedItem.tokenId] === $userAddress}
                <div class="mt-2">
                    <button
                        type="button"
                        class="hovertext text-sm"
                        on:click={() => {showTransferMenu = !showTransferMenu}}
                    >
                        Transfer ownership
                        <i class="bi bi-chevron-{showTransferMenu ? 'up' : 'down'}" />
                    </button>
                </div>
                {#if showTransferMenu}
                    <div in:slide out:slide>
                        <div class="text-slate-500 text-sm pl-3 mt-3">
                            Recipient
                        </div>
                        <div class="flex">
                            <input
                                type="text"
                                placeholder="Enter recipient's address here..."
                                class="focus:outline-0 w-full rounded-full px-4 py-1 bg-transparent border-2 border-slate-400 focus:border-sky-600 hover:border-slate-500"
                                bind:value={recipientAddress}
                            />   
                            <button
                                type="button"
                                on:click={handleTransfer}
                                class="ml-2 bg-sky-600 hover:bg-sky-800 text-white font-bold whitespace-nowrap rounded-full px-3 py-1 disabled:bg-slate-300 disabled:hover:bg-slate-300"
                                disabled={recipientAddress.length !== 42 || isTransferring}
                            >
                                <i class="bi bi-send" />
                            </button>
                        </div>
                        {#if errorMessage}
                            <div class="text-rose-600 mt-3" in:slide>
                                {errorMessage}
                            </div>
                        {/if}

                        {#if isTransferring && !errorMessage}
                            <div class="mt-6" in:slide>
                                <div class="flex justify-between mt-3">
                                    {#each ["Confirming", "Submitting", "Finalizing"] as stage}
                                        <div>{stage}</div>
                                    {/each}
                                </div>
                                <div class="w-full bg-slate-300 rounded-full h-3">
                                    <div
                                        class="bg-sky-600 h-3 rounded-full"
                                        style="width: {$progress * 100}%"
                                    />
                                </div>
                            </div>
                        {/if}
                    </div>
                {/if}
            {/if}
        {/if}
    </div>
</div>



<style lang="postcss">
    th {
        @apply pr-3 align-top text-left whitespace-nowrap;
    }
</style>
