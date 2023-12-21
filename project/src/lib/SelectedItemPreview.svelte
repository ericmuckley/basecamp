<script>
    import { fly, slide } from 'svelte/transition';
    import CopyText from '$lib/CopyText.svelte';
    import { shortHash } from '$lib/utils.js';
    import { userAddress } from '$lib/stores.js'
	import { CHAIN_ID, BLOCK_EXPLORER_URL, CONTRACT_ADDRESS, CONTRACT_METADATA } from '$lib/contract_settings.js';

    export let selectedItem;
    export let owners;
    let showTransferMenu = false;
	let transferError;
    let recipientAddress;

    /*
	const handleTransfer = async () => {

        if (recipientAddress.length !== 42) {
            transferError = "Invalid recipient address";
            return;
        };

        errorMessage = null;
        progress.set(0.0);
        progress.set(0.1);
        let parentHash = (selectedVersioning === 'versioning-root' ) ? toHex(pad(0)) : parentHashInput;
        const { chain } = getNetwork();
        try {
            const result =  await writeContract({
                address: CONTRACT_ADDRESS,
                abi: CONTRACT_METADATA.output.abi,
                functionName: 'safeTransferFrom',
                chainId: CHAIN_ID,
                args: [$userAddress, recipientAddress, selectedTokenId],
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
    */




</script>



<div
    in:fly={{ y:100, duration:300 }}
    class="bg-slate-200 rounded-tr-3xl rounded-bl-3xl absolute top-0 right-0 px-5 py-4"
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
                    <CopyText text={CONTRACT_ADDRESS} />
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
                        <th class="pr-3">Creator <CopyText text={selectedItem.creator}/></th>
                        <td>
                            <a href="{BLOCK_EXPLORER_URL}/address/{selectedItem.creator}" target="_blank">
                                {shortHash(selectedItem.creator, 6)}
                                <i class="bi bi-box-arrow-up-right" />
                            </a>
                        </td>
                    </tr>	
                    <tr>
                        <th class="pr-3">Owner <CopyText text={owners.byTokenId[selectedItem.tokenId]}/></th>
                        <td>
                            <a href="{BLOCK_EXPLORER_URL}/address/{owners.byTokenId[selectedItem.tokenId]}" target="_blank">
                                {shortHash(owners.byTokenId[selectedItem.tokenId], 6)}
                                <i class="bi bi-box-arrow-up-right" />
                            </a>
                        </td>
                    </tr>              
                    <tr>
                        <th class="pr-3">File hash <CopyText text={selectedItem.hash}/></th>
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
                <div class="mt-3">
                    <button
                        type="button"
                        class="hovertext text-sm"
                        on:click={() => {showTransferMenu = !showTransferMenu}}
                    >
                        <i class="bi bi-chevron-down" />
                        Transfer ownership
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
                                class="bg-sky-600 hover:bg-sky-800 text-white font-bold whitespace-nowrap rounded-full px-4 py-1"
                            >
                                <i class="bi bi-send mr-2" />Transfer
                            </button>                            
                        </div>

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
