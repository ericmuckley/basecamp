
<script>
    import { readContract, writeContract } from '@wagmi/core';
    import { CHAIN_ID, BLOCK_EXPLORER_URL, CONTRACT_ADDRESS, CONTRACT_METADATA } from '$lib/contract_settings.js';
    import { onMount } from 'svelte';
    import { fly } from 'svelte/transition';

    export let uploadedFile;
    let verifiedItem;

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
		{ field: 'keccak256', label: 'Keccak256 Hash', format: (s) => {
            return `${s.slice(0, 24)}...${s.slice(s.length - 24, s.length)}`
        } },
        /*
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
        */
	];


    // when file is uploaded, check if it has previously been verified onchain
    onMount(async() => {
        let item = await readContract({
            address: CONTRACT_ADDRESS,
            abi: CONTRACT_METADATA.output.abi,
            functionName: 'getItemByHash',
            chainId: CHAIN_ID,
            args: [uploadedFile.keccak256],
        });
        if (item.hash === uploadedFile.keccak256) {
            uploadedFile.isVerified = true;
            verifiedItem = item;
        } else {
            uploadedFile.isVerified = false;
        };
    });


	const handlePublish = async () => {
        const result =  await writeContract({
            address: CONTRACT_ADDRESS,
            abi: CONTRACT_METADATA.output.abi,
            functionName: 'createItem',
            chainId: CHAIN_ID,
            args: [uploadedFile.name, uploadedFile.description, uploadedFile.keccak256],
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


{#if uploadedFile}
    <div class="box shadow-xl shadow-indigo-600">
        <div class="flex justify-between">
            <h3>{uploadedFile.name}</h3>
            <div>
                <button
                    type="button"
                    class="text-xl text-indigo-500 hover:text-indigo-800"
                    on:click={() => {
                        uploadedFile = null;
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
                                {field.format(uploadedFile[field.field])}
                            {:else}
                                {uploadedFile[field.field]}
                            {/if}
                        </td>
                    </tr>
                {/each}
            </table>
        </div>

        {#if uploadedFile.isVerified === true}
            <div class="mt-8 rounded-3xl bg-emerald-100 p-6" in:fly={{ y: -100, diration: 800 }}>
                <h4 class="font-bold text-xl text-emerald-600">
                    <i class="bi bi-shield-fill-check mr-1" />
                    This file has been published onchain
                </h4>
                <div class="mt-3">
                    <table class="border-spacing-y-4">
                        <tr class="text-slate-600">
                            <td class="font-bold whitespace-nowrap pr-6">Block published</td>
                            <td>
                                <a
                                    target="_blank"
                                    href="{BLOCK_EXPLORER_URL}/block/{Number(verifiedItem.blockCreated)}"
                                >
                                    {Number(verifiedItem.blockCreated)}
                                    <i class="bi bi-box-arrow-right ml-1" />
                                </a>
                            </td>
                        </tr>
                        <tr class="text-slate-600">
                            <td class="font-bold whitespace-nowrap pr-6">Published by</td>
                            <td>
                                <a
                                    target="_blank"
                                    href="{BLOCK_EXPLORER_URL}/address/{verifiedItem.creator}"
                                >
                                    {verifiedItem.creator.slice(0, 6)}
                                    <i class="bi bi-box-arrow-right ml-1" />
                                </a>
                            </td>
                        </tr>
                        <tr class="text-slate-600">
                            <td class="font-bold whitespace-nowrap pr-6">Description</td>
                            <td class="italic">{verifiedItem.description}</td>
                        </tr>
                    </table>
                </div>
            </div>

        {:else if uploadedFile.isVerified === false}
            <div class="mt-8" in:fly={{ y: -100, diration: 800 }}>
                <h4 class="text-xl text-slate-600">
                    This file has not been published onchain using the publisher contract
                </h4>


                <div class="flex">
                    <div>File title</div>
                    <input
                        type="text"
                        placeholder="Enter filename here..."
                        bind:value={uploadedFile.name}
                    />                    
                </div>
                <div class="flex mt-3">
                    <div>File Description</div>
                    <textarea
                        rows="2"
                        bind:value={uploadedFile.description}
                        placeholder="Enter file description here..."
                    ></textarea>
                </div>

                <button
                    type="button"
                    class="mt-2 w-full rounded-full px-6 py-1 text-lg bg-indigo-600 hover:bg-indigo-800 text-white"
                    on:click={handlePublish}
                >
                    <i class="bi bi-file-earmark-lock-fill mr-2"/>Publish Now
                </button>                
            </div>

        {:else}
            <div class="animate-pulse flex space-x-4" in:fly={{ y: -100, diration: 800 }}>
                <div class="flex-1 space-y-6 py-1">
                    <div class="h-2 bg-slate-600 rounded"></div>
                    <div class="h-6 bg-slate-600 rounded"></div>
                </div>
            </div>
        {/if}
    </div>

{/if}