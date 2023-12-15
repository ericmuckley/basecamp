<script>
    import { userAddress, networkId } from '$lib/stores.js';
    import { BLOCK_EXPLORER_URL, CONTRACT_ADDRESS } from '$lib/contract_settings.js'

    export let handleConnectWallet = () => {};
</script>


<nav>
    <div class="px-4 py-3 flex justify-between">

        <div class="flex space-x-6">
            <div class="text-slate-300 cursor-default font-bold text-2xl font-mono">
                publish + verify
                <a
                    href="{BLOCK_EXPLORER_URL}address/{CONTRACT_ADDRESS}"
                    target="_blank"
                    class="text-sky-300 hover:text-sky-100"
                >
                    <i class="bi bi-box-arrow-right ml-2" />
                </a>
            </div>                      
        </div>

        <button
            type="button"
            on:click={handleConnectWallet}
            class="login-button tracking-[0.1em]"
        >
            {#if $userAddress && $networkId}
                <i class="bi bi-gear mr-5" />{$userAddress.slice(0, 6)}
            {:else}
                <i class="bi bi-wallet mr-5" />Connect wallet
            {/if}
        </button>

    </div>
</nav>