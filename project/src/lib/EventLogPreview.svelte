<script>

    import { CHAIN_ID, BLOCK_EXPLORER_URL, CONTRACT_ADDRESS, CONTRACT_METADATA } from '$lib/contract_settings.js';

    export let log;

	const shortHash = (s, n = 16) => {
		return `${s.slice(0, n)}...${s.slice(s.length - n, s.length)}`;
	};

</script>

<div class="rounded-2xl bg-white border border-slate-200 text-slate-600 px-6 py-6 shadow-xl">
    {#if log}
        <div class="text-xs">
            keccak256 {shortHash(log.item.hash)}
        </div>
        <div class="font-bold text-2xl my-2">
            {log.item.name}
        </div>
        <div class="text-lg italic my-1">
            {log.item.description}
        </div>
        <div class="text-xs">
            {log.timestamp}
        </div>
        <div class="text-xs">
            Published by
            <a
                href="{BLOCK_EXPLORER_URL}/address/{log.item.creator}"
                target="_blank"
            >
                {log.item.creator.slice(0, 6)}
                <i class="bi bi-box-arrow-right ml-1" />
            </a>						
        </div>
        <div class="text-xs">
            <a
                href="{BLOCK_EXPLORER_URL}/tx/{log.transactionHash}"
                target="_blank"
            >
                View transaction on block explorer
                <i class="bi bi-box-arrow-right ml-1" />
            </a>
        </div>
    {/if}
</div>