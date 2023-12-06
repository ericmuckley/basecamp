<script>

    import { getAccount } from '@wagmi/core';
    import { userAddress, networkId } from '$lib/stores.js';
    import Layout from '../routes/+layout.svelte';

    export let handleConnectWallet = () => {};
</script>


<nav>
    <div class="px-4 py-3 flex justify-between bg-indigo-200">

        <div>
            <h3 class="text-indigo-600 cursor-default">
                publish / verify
            </h3>
        </div>

        <button
            type="button"
            on:click={handleConnectWallet}
            class="px-6 py-1 rounded-full bg-indigo-600 hover:bg-indigo-800 text-white text-lg"
        >
            {#if $userAddress && $networkId}
                <i class="bi bi-gear-fill mr-2" />{$userAddress.slice(0, 6)}
            {:else}
                <i class="bi bi-wallet mr-2" />Connect wallet
            {/if}
               

        </button>

    </div>
</nav>