<script>
    import CopyText from '$lib/CopyText.svelte';
	import { BLOCK_EXPLORER_URL } from '$lib/contract_settings.js';

    export let logs;
    export let filter;

    const fields = [
        {
            label: "ID",
            wrap: false,
            content: (log) => {return log.item.tokenId},
            display: (log) => {return Number(log.item.tokenId)},
        },
        {
            label: "Item name",
            wrap: true,
            icon: "file-earmark-fill",
            display: (log) => {return log.item.name},
        },
        {
            label: "Item description",
            wrap: true,
            icon: 'card-text',
            display: (log) => {return log.item.description},
        },
        {
            label: "Hash",
            wrap: false,
            icon: 'qr-code',
            copy: (log) => {return log.item.hash},
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
            display: (log) => {
                let h = log.item.parentHash;
                if ([...new Set(h)].length == 2) {
                    return "";
                } else {
                    let parentTxn = logs.find(x => x.args._hash == log.item.parentHash).transactionHash;
                    return `
                    <a href="${BLOCK_EXPLORER_URL}tx/${parentTxn}" target="_blank">
                        ${shortHash(log.item.parentHash, 6)}
                        <i class="bi bi-box-arrow-up-right" />
                    </a>`;
                };
            },
        },
        {
            label: "Creator",
            wrap: false,
            icon: "person-circle",
            copy: (log) => {return log.item.creator},
            display: (log) => {
                return `
                <a href="${BLOCK_EXPLORER_URL}/address/${log.item.creator}" target="_blank">
                    ${shortHash(log.item.creator, 6)}
                    <i class="bi bi-box-arrow-up-right" />
                </a>`
            },
        },
        {
            label: "Creation time",
            wrap: false,
            icon: "calendar",
            display: (log) => {return log.timestamp},
        },

    ]

	const shortHash = (s, n = 6) => {
		return `${s.slice(0, n)}...${s.slice(s.length - n, s.length)}`;
	};

</script>

<table>
    <thead>
        {#each fields as field}
            <th>
                {#if field.icon}
                    <i class="bi bi-{field.icon} mr-1" />
                {/if}
                {field.label}
            </th>
        {/each}
    </thead>
    <tbody>
        {#each logs as log}
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
        @apply pr-6 py-2 text-slate-600 align-top text-left whitespace-nowrap border-b-2 border-slate-300;
    }
    td {
        @apply pr-6 py-2 text-left align-top text-slate-600;
    }
    tr {
        @apply border-b border-slate-300;
    }
    tr:last-child {
        @apply border-0;
    }

</style>
