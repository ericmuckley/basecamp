<script>

    import { CHAIN_ID, BLOCK_EXPLORER_URL, CONTRACT_ADDRESS, CONTRACT_METADATA } from '$lib/contract_settings.js';

    export let log;

	const shortHash = (s, n = 16) => {
		return `${s.slice(0, n)}...${s.slice(s.length - n, s.length)}`;
	};

</script>

<div class="rounded-2xl border border-slate-300 text-slate-600 px-6 py-6 shadow-lg">
    {#if log}
        <div class="text-sm">
            <a
                href="{BLOCK_EXPLORER_URL}/tx/{log.transactionHash}"
                target="_blank"
            >
                {shortHash(log.item.hash, 8)}
                <i class="bi bi-box-arrow-right ml-1" />
            </a>
            
        </div>
        <div class="font-bold text-2xl my-2">
            {log.item.name}
        </div>
        {#if log.item.description && log.item.description.length}
            <div class="text-xl italic my-1">
                <i class="bi bi-card-text mr-1" />
                {log.item.description}
            </div> 
        {/if}
        <div class="text-sm mt-2">
            <i class="bi bi-calendar mr-2" />{log.timestamp}
        </div>
        <div class="text-sm mt-1">
            <i class="bi bi-person-circle mr-2" />Published by
            <a
                href="{BLOCK_EXPLORER_URL}/address/{log.item.creator}"
                target="_blank"
            >
                {log.item.creator.slice(0, 6)}
                <i class="bi bi-box-arrow-right ml-1" />
            </a>						
        </div>
    {/if}
</div>