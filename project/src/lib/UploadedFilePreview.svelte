
<script>
    import { pad, toHex} from 'viem';
    import { readContract, writeContract, waitForTransaction, getNetwork } from '@wagmi/core';
    import { CHAIN_ID, BLOCK_EXPLORER_URL, CONTRACT_ADDRESS, CONTRACT_METADATA } from '$lib/contract_settings.js';
    import { onMount } from 'svelte';
    import { fly } from 'svelte/transition';
    import { tweened } from 'svelte/motion';
    import { cubicOut } from 'svelte/easing';

    export let getLogs = () => {};
    export let uploadedFile;
    let selectedVersioning = 'versioning-root';
    let verifiedItem;
    let parentHashInput = "";
    let errorMessage;

    const progress = tweened(0.0, {duration: 6000, easing: cubicOut});

	const DISPLAY_FIELDS = [
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
	];


    const VERSIONING_OPTIONS = [
        {
            id: 'root',
            label: 'New root file',
            description: "This file has not been published and no previous versions of it have been published",
        },
        {
            id: 'version',
            label: "New version of an existing file",
            description: "This is a new version of a file that was previously published",
        },
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
        errorMessage = null;
        progress.set(0.0);
        progress.set(0.1);
        let parentHash = (selectedVersioning == 'versioning-root' ) ? toHex(pad(0)) : parentHashInput;
        const { chain } = getNetwork();
        try {
            const result =  await writeContract({
                address: CONTRACT_ADDRESS,
                abi: CONTRACT_METADATA.output.abi,
                functionName: 'createItem',
                chainId: CHAIN_ID,
                args: [
                    uploadedFile.name,
                    uploadedFile.description,
                    uploadedFile.keccak256,
                    parentHash,
                ],
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
            if (error.message.includes("OnlyOwnerCanAddNewVersion")) {
                errorMessage = "Only the owner of the root file can add new versions to it";
            } else if (error.message.includes('ParentHashHasNotBeenPublished')) {
                errorMessage = "The parent file hash you entered has not been published to this contract"
            } else if (error.message.includes('does not match expected size')) {
                errorMessage = "The parent hash value is not valid";
            };
        };
        getLogs();
    };

</script>


{#if uploadedFile}
    <div class="box bg-slate-100 shadow-xl">
        <div class="flex justify-between">
            <h3>{uploadedFile.name}</h3>
            <div>
                <button
                    type="button"
                    class="text-xl text-slate-600 hover:text-slate-900"
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
                {#each DISPLAY_FIELDS as field}
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
        <hr  class="mt-6" />
        {#if uploadedFile.isVerified === true}
            <div class="mt-8" in:fly={{ y: -100, duration: 800 }}>
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

            <div class="mt-8" in:fly={{ y: -100, duration: 800 }}>

                {#if $progress < 0.01}

                    <h4 class="text-slate-600">
                        This file has not been published to this contract.
                        You can publish it now with a custom name and description.
                    </h4>

                    <div class="text-slate-500 text-sm pl-3 mt-6">
                        File title
                    </div>
                    <input
                        type="text"
                        placeholder="Enter filename here..."
                        class="focus:outline-0 w-full rounded-xl px-4 py-1 bg-transparent border-2 border-slate-400 focus:border-sky-600 hover:border-slate-500"
                        bind:value={uploadedFile.name}
                    />                    

                    
                    <div class="text-slate-500 text-sm pl-3 mt-3">
                        File Description
                    </div>
                    <textarea
                        rows="2"
                        bind:value={uploadedFile.description}
                        placeholder="Enter file description here..."
                        class="focus:outline-0 w-full rounded-xl px-4 py-1 bg-transparent border-2 border-slate-400 focus:border-sky-600 hover:border-slate-500"
                    ></textarea>




                    <ul class="grid grid-cols-2 w-full gap-6 my-4">
                        {#each VERSIONING_OPTIONS as option}
                            <li>
                                <input
                                    type="radio"
                                    id="versioning-{option.id}"
                                    name="versioning"
                                    value="versioning-{option.id}"
                                    class="hidden peer"
                                    bind:group={selectedVersioning}
                                    on:input={() => {errorMessage = null}}
                                    required
                                >
                                <label
                                    for="versioning-{option.id}"
                                    class="inline-flex items-center justify-between w-full px-6 py-3 border-2 border-slate-200 rounded-2xl cursor-pointer text-slate-400 peer-checked:border-sky-600 peer-checked:text-sky-600  hover:text-slate-600 hover:bg-slate-200"
                                >                           
                                    <div class="block">
                                        <div class="w-full text font-bold">
                                            {option.label}
                                        </div>
                                        <div class="w-full text-xs">
                                            {option.description}
                                        </div>
                                    </div>
                                </label>
                            </li>
                        {/each}
                    </ul>
                    {#if selectedVersioning == 'versioning-version'}
                        <div in:fly={{ y: -20, duration: 200 }} class="mb-6">
                            <div class="text-slate-500 text-sm pl-3 mt-6">
                                Parent file hash
                            </div>
                            <input
                                type="text"
                                placeholder="Enter parent file keccak256 hash..."
                                class="focus:outline-0 w-full rounded-xl px-4 py-1 bg-transparent border-2 border-slate-400 focus:border-sky-600 hover:border-slate-500"
                                bind:value={parentHashInput}
                                on:input={() => {errorMessage = null}}
                            />                               
                        </div>
                    {/if}

                    
                    {#if errorMessage}
                        <div
                            in:fly={{ y: -100, duration: 800 }}
                            class="my-6 rounded-3xl py-4 px-6 text-xl bg-rose-200 text-rose-800"
                        >
                            <i class="bi bi-exclamation-triangle-fill mr-1" />
                            {errorMessage}
                        </div>
                    {/if}


                    <button
                        type="button"
                        class="login-button py-2 mt-2 w-full text-xl"
                        on:click={handlePublish}
                    >
                        <i class="bi bi-send mr-2"/>Publish Now
                    </button>

                {:else}

                    <div>
                        File submitted! Please confirm transaction in your wallet.
                    </div>

                    <div class="flex justify-between mt-3">
                        {#each ["Confirming", "Submitting", "Finalizing"] as stage}
                            <div>{stage}</div>
                        {/each}
                    </div>
                    <div class="w-full bg-slate-300 rounded-full h-4">
                        <div
                            class="bg-emerald-600 h-4 rounded-full"
                            style="width: {$progress * 100}%"
                        />
                    </div>

                {/if}

            </div>

        {:else}
            <div class="animate-pulse flex space-x-4" in:fly={{ y: -100, duration: 800 }}>
                <div class="flex-1 space-y-6 py-1">
                    <div class="h-2 bg-slate-600 rounded"></div>
                    <div class="h-6 bg-slate-600 rounded"></div>
                </div>
            </div>
        {/if}
    </div>

{/if}
