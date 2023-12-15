<script>
    import { toHex, pad } from 'viem';
    import { BLOCK_EXPLORER_URL } from '$lib/contract_settings.js';

    export let log;
    export let logs;
    let hashCopied = false;
    let parentHashCopied = false;

	const shortHash = (s, n = 16) => {
		return `${s.slice(0, n)}...${s.slice(s.length - n, s.length)}`;
	};

    const delay = ms => new Promise(res => setTimeout(res, ms));

    const copyHash = async () => {
        navigator.clipboard.writeText(log.item.hash);
        hashCopied = true;
        await delay(1000);
        hashCopied = false;
    }

    const copyParentHash = async () => {
        navigator.clipboard.writeText(log.item.parentHash);
        parentHashCopied = true;
        await delay(1000);
        parentHashCopied = false;
    }

</script>

<div class="rounded-2xl border border-slate-300 text-slate-600 px-6 py-6">
    {#if log}
        <div class="text-sm flex justify-between">
            <a
                href="{BLOCK_EXPLORER_URL}tx/{log.transactionHash}"
                target="_blank"
            >
                {shortHash(log.item.hash, 8)}
                <i class="bi bi-box-arrow-right ml-1" />
            </a>

            <div class="text-slate-600">
                {#if hashCopied}
                    <i class="bi bi-check-lg" />   
                {:else}         
                    <button
                        type="button"
                        class="hovertext"
                        on:click={copyHash}
                    >
                        <i class="bi bi-copy" />
                    </button>
                {/if}       
            </div>
        </div>
        <div>
            {#if log.item.parentHash == toHex(pad(0))}
                <span class="text-slate-600 italic text-sm">Root file (no previous versions exist)</span>
            {:else}
                <div class="text-sm flex justify-between italic">
                    <div>
                        Child version of
                        <a
                            href="{BLOCK_EXPLORER_URL}tx/{logs.find(x => x.args._hash == log.item.parentHash).transactionHash}"
                            target="_blank"
                        >
                            {shortHash(log.item.parentHash, 8)}
                            <i class="bi bi-box-arrow-right ml-1" />
                        </a>
                        
                    </div>
                    <div class="text-slate-600">
                        {#if parentHashCopied}
                            <i class="bi bi-check-lg" />   
                        {:else}         
                            <button
                                type="button"
                                class="hovertext"
                                on:click={copyParentHash}
                            >
                                <i class="bi bi-copy" />
                            </button>
                        {/if}       
                    </div>
                </div>
            {/if}            
        </div>



        <div class="font-bold text-xl my-2">
            {log.item.name}
        </div>
        {#if log.item.description && log.item.description.length}
            <div class="text-sm italic my-1">
                <i class="bi bi-info-circle-fill mr-1" />
                {log.item.description}
            </div> 
        {/if}
        <div class="text-xs">
            <i class="bi bi-calendar mr-2" />{log.timestamp}
        </div>
        <div class="text-xs">
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