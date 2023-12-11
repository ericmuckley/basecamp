<script>

    import { getAccount } from '@wagmi/core';
    import { userAddress, networkId } from '$lib/stores.js';
    import Layout from '../routes/+layout.svelte';

    export let handleConnectWallet = () => {};
</script>


<nav>
    <div class="px-4 py-3 flex justify-between">

        <div>
            <div class="text-slate-300 cursor-default font-bold text-3xl font-mono">
                publish + verify
            </div>
        </div>

        <button
            type="button"
            on:click={handleConnectWallet}
            class="login-button"
        >
            {#if $userAddress && $networkId}
                <i class="bi bi-gear mr-2" />{$userAddress.slice(0, 6)}
            {:else}
                <i class="bi bi-wallet mr-2" />Connect wallet
            {/if}
               

        </button>

    </div>
</nav>