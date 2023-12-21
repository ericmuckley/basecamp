<script>
    import CopyText from '$lib/CopyText.svelte';
    import { shortHash } from '$lib/utils.js';
    import { userAddress } from '$lib/stores.js'
	import { CHAIN_ID, BLOCK_EXPLORER_URL, CONTRACT_ADDRESS, CONTRACT_METADATA } from '$lib/contract_settings.js';

    export let selectedItem;

	let transferError;

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





</script>



<div class="bg-slate-200 rounded-tr-3xl rounded-bl-3xl absolute top-0 right-0 px-5 py-4">
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
                        <td>
                            {selectedItem.description}
                        </td>
                    </tr>
                </table>
            </div>
        {/if}
    </div>
</div>



<style lang="postcss">
    th {
        @apply pr-3 align-top text-left whitespace-nowrap;
    }
</style>
