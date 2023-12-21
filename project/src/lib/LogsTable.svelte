<script>
    import CopyText from '$lib/CopyText.svelte';
	import { BLOCK_EXPLORER_URL } from '$lib/contract_settings.js';
    import { shortHash } from '$lib/utils.js';
    import { onMount } from 'svelte';

    export let logs;
    export let filter;
    export let owners;
    let filterField = "ID";
    let filterDirection = -1;
    let filteredLogs = [...logs];
   
    const fields = [
        {
            label: "ID",
            wrap: false,
            content: (log) => {return Number(log.item.tokenId)},
            display: (log) => {return Number(log.item.tokenId)},
        },
        {
            label: "Item name",
            wrap: true,
            icon: "file-earmark-fill",
            content: (log) => {return log.item.name},
            display: (log) => {return log.item.name},
        },
        {
            label: "Item description",
            wrap: true,
            icon: 'card-text',
            content: (log) => {return log.item.description},
            display: (log) => {return log.item.description},
        },
        {
            label: "Creation time",
            wrap: false,
            icon: "calendar",
            content: (log) => {return log.timestamp},
            display: (log) => {return log.timestamp},
        },
        {
            label: "Owner",
            wrap: false,
            icon: "person-fill-lock",
            copy: (log) => {return owners.byTokenId[log.item.tokenId]},
            content: (log) => {return owners.byTokenId[log.item.tokenId]},
            display: (log) => {
                return `
                <a href="${BLOCK_EXPLORER_URL}/address/${owners.byTokenId[log.item.tokenId]}" target="_blank">
                    ${shortHash(owners.byTokenId[log.item.tokenId], 6)}
                    <i class="bi bi-box-arrow-up-right" />
                </a>`
            },
        },
        {
            label: "Creator",
            wrap: false,
            icon: "person-add",
            copy: (log) => {return log.item.creator},
            content: (log) => {return log.item.creator},
            display: (log) => {
                return `
                <a href="${BLOCK_EXPLORER_URL}/address/${log.item.creator}" target="_blank">
                    ${shortHash(log.item.creator, 6)}
                    <i class="bi bi-box-arrow-up-right" />
                </a>`
            },
        },
        {
            label: "Hash",
            wrap: false,
            icon: 'qr-code',
            copy: (log) => {return log.item.hash},
            content: (log) => {return log.item.hash},
            display: (log) => {
                return `
                <a href="${BLOCK_EXPLORER_URL}tx/${log.transactionHash}" target="_blank">
                    ${shortHash(log.item.hash, 6)}
                    <i class="bi bi-box-arrow-up-right" />
                </a>`
            },
        },
        {
            label: "Parent hash",
            wrap: false,
            icon: 'diagram-2-fill',
            copy: (log) => {return log.item.parentHash},
            content: (log) => {return log.item.parentHash},
            display: (log) => {
                let h = log.item.parentHash;
                if ([...new Set(h)].length === 2) {
                    return "";
                } else {
                    let parentTxn = logs.find(x => x.args._hash === log.item.parentHash).transactionHash;
                    return `
                    <a href="${BLOCK_EXPLORER_URL}tx/${parentTxn}" target="_blank">
                        ${shortHash(log.item.parentHash, 6)}
                        <i class="bi bi-box-arrow-up-right" />
                    </a>`;
                };
            },
        },
    ];


    onMount(() => {
        filterAndSort();
    })


    $: filter, filterAndSort();


    function filterAndSort() {
        // perform filtering
        let filtered = [];
        for (let log of logs) {
            if (filter.trim().length) {
                for (let field of fields) {
                    if (field.content(log).toString().includes(filter)) {
                        filtered.push(log);
                        break;
                    }
                }
            } else {
                filtered.push(log);
            }
        }
        // perform sorting
        let content = fields.find(f => f.label === filterField).content;
        if (filterDirection > 0) {
            filtered.sort((a, b) => (content(a) > content(b)) ? 1 : ((content(b) > content(a)) ? -1 : 0));
        } else {
            filtered.sort((a, b) => (content(a) < content(b)) ? 1 : ((content(b) < content(a)) ? -1 : 0));
        }
        filteredLogs = [...filtered];
    };

</script>


<table>
    <thead>
        {#each fields as field}
            <th>
                <button
                    class="px-5 py-2 rounded-full {
                    filterField === field.label ? 'bg-sky-200' : 'hover:bg-slate-200'}"
                    on:click={() => {
                        filterField = field.label;
                        filterDirection = -filterDirection;
                        filterAndSort();
                    }}
                >
                    {#if filterField === field.label}
                        <i class="bi bi-{filterDirection < 1 ? 'caret-down-fill': 'caret-up-fill' } mr-2" />
                    {/if}
                    {#if field.icon}
                        <i class="bi bi-{field.icon} mr-1" />
                    {/if}
                    {field.label}                
                </button>
            </th>
        {/each}
    </thead>
    <tbody>
        {#each filteredLogs as log}
            <tr>
                {#each fields as field}
                    <td class="{field.wrap ? '' : 'whitespace-nowrap'}">
                        {#if field.copy && field.display(log).length}
                            <span class="mr-1">
                                <CopyText text={field.copy(log)} />
                            </span>
                        {/if}
                        {@html field.display(log)}
                    </td>
                {/each}
            </tr>
        {/each}
    </tbody>
</table>


<style lang="postcss">
    table {
        @apply text-sm;
    }
    th {
        @apply pr-1 py-2 text-slate-600 align-top text-left whitespace-nowrap border-b-2 border-slate-300;
    }
    td {
        @apply pl-6 py-2 text-left align-top text-slate-600;
    }
    tr {
        @apply border-b border-slate-300;
    }
    tr:last-child {
        @apply border-0;
    }

</style>
