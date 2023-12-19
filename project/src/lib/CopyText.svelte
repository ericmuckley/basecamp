<script>

    export let text = "";
    let copied = false;

    const delay = ms => new Promise(res => setTimeout(res, ms));

    const copyHash = async () => {
        navigator.clipboard.writeText(text);
        copied = true;
        await delay(1000);
        copied = false;
    }

</script>


<span class="text-slate-600">
    {#if copied}
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
</span>