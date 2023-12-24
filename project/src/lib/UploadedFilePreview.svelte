
<script>
    import { pad, toHex} from 'viem';
    import { readContract, writeContract, waitForTransaction, getNetwork } from '@wagmi/core';
    import { CHAIN_ID, BLOCK_EXPLORER_URL, CONTRACT_ADDRESS, CONTRACT_METADATA } from '$lib/contract_settings.js';
    import { shortHash, NULL_ADDRESS } from '$lib/utils.js';
    import { onMount } from 'svelte';
    import { fly } from 'svelte/transition';
    import { tweened } from 'svelte/motion';
    import { cubicOut } from 'svelte/easing';
    import CopyButton from '$lib/CopyButton.svelte';

    export let logs;
    export let owners;
    export let uploadedFile;
    let selectedVersioning = 'versioning-root';
    let parentHashInput = "";
    let verifiedItem;
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
            description: "Neither this file not previous versions of it have been published",
        },
        {
            id: 'version',
            label: "New version of an existing file",
            description: "This is a new version of a file that was previously published",
        },
    ];




    
    // when file is uploaded, check if it has previously been verified onchain
    onMount(async() => {
        // compare the uploaded file against the logs of previous files
        verifiedItem = logs.find(log => log.item.hash.toLowerCase() === uploadedFile.keccak256.toLowerCase());
        console.log("CHECKING")
        console.log(logs.map(x => x.item.hash), uploadedFile.keccak256)
        console.log(verifiedItem)

        if (verifiedItem) {
            let tokenId = verifiedItem.item.tokenId;
            verifiedItem.owner = owners.byTokenId[tokenId];
        };
        /*
        // In this version, we use a contract view function
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
        */
    });
    


	const handlePublish = async () => {
        errorMessage = null;
        progress.set(0.0);
        progress.set(0.1);
        let parentHash = (selectedVersioning === 'versioning-root' ) ? toHex(pad(0)) : parentHashInput;
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
            location.reload();
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
    };

</script>


{#if uploadedFile}
    <div class="box bg-slate-100 shadow-xl">
        <div class="flex justify-between">
            <h3>{uploadedFile.name}</h3>
            <div>
                <button
                    type="button"
                    class="text-xl hovertext"
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

        {#if verifiedItem}
            <div class="mt-8" in:fly={{ y: -100, duration: 800 }}>
                <h4 class="font-bold text-xl text-sky-600">
                    <i class="bi bi-shield-fill-check mr-1" />
                    This item has been published
                </h4>
                <div class="mt-3">
                    <table class="border-spacing-y-4 text-slate-600">
                        <tr>
                            <td class="font-bold whitespace-nowrap pr-6">Name</td>
                            <td class="italic">{verifiedItem.item.name}</td>
                        </tr>
                        <tr>
                            <td class="font-bold whitespace-nowrap pr-6">Description</td>
                            <td class="italic">{verifiedItem.item.description}</td>
                        </tr>                        
                        <tr>
                            <td class="font-bold whitespace-nowrap pr-6">Publication time</td>
                            <td>
                                {verifiedItem.timestamp}
                            </td>
                        </tr>

                        <tr>
                            <td class="font-bold whitespace-nowrap pr-6">Block published</td>
                            <td>
                                <a
                                    target="_blank"
                                    href="{BLOCK_EXPLORER_URL}/block/{Number(verifiedItem.item.blockCreated)}"
                                >
                                    {Number(verifiedItem.item.blockCreated)}
                                    <i class="bi bi-box-arrow-right ml-1" />
                                </a>
                            </td>
                        </tr>
                        <tr>
                            <td class="font-bold whitespace-nowrap pr-6">Published by</td>
                            <td>
                                <span class="mr-2">
                                    <CopyButton text={verifiedItem.item.creator} />
                                </span>
                                <a
                                    target="_blank"
                                    href="{BLOCK_EXPLORER_URL}/address/{verifiedItem.item.creator}"
                                >
                                    {verifiedItem.item.creator.slice(0, 6)}
                                    <i class="bi bi-box-arrow-right ml-1" />
                                </a>
                            </td>
                        </tr>
                        <tr>
                            <td class="font-bold whitespace-nowrap pr-6">Owner</td>
                            <td>
                                <span class="mr-2">
                                    <CopyButton text={verifiedItem.owner} />
                                </span>
                                <a
                                    target="_blank"
                                    href="{BLOCK_EXPLORER_URL}/address/{verifiedItem.owner}"
                                >
                                    {verifiedItem.owner.slice(0, 6)}
                                    <i class="bi bi-box-arrow-right ml-1" />
                                </a>
                            </td>
                        </tr>
                        <tr>
                            <td class="font-bold whitespace-nowrap pr-6">Token ID</td>
                            <td>{Number(verifiedItem.item.tokenId)}</td>
                        </tr>
                        <tr>
                            <td class="font-bold whitespace-nowrap pr-6">Parent hash</td>
                            <td>
                                {#if verifiedItem.item.parentHash === NULL_ADDRESS }
                                    <span class="italic text-slate-400">
                                        This is a root file and has no parent
                                    </span>
                                {:else}
                                    <span class="mr-2">
                                        <CopyButton text={verifiedItem.item.parentHash} />
                                    </span>
                                    {shortHash(verifiedItem.item.parentHash, 6)}
                                {/if}
                            </td>
                        </tr>
                    </table>
                </div>
            </div>

        {:else}

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
                    {#if selectedVersioning === 'versioning-version'}
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
                        Item submitted! Please confirm transaction in your wallet.
                    </div>

                    <div class="flex justify-between mt-3">
                        {#each ["Confirming", "Submitting", "Finalizing"] as stage}
                            <div>{stage}</div>
                        {/each}
                    </div>
                    <div class="w-full bg-slate-300 rounded-full h-4">
                        <div
                            class="bg-sky-600 h-4 rounded-full"
                            style="width: {$progress * 100}%"
                        />
                    </div>

                {/if}

            </div>

        {/if}
    </div>

{/if}
