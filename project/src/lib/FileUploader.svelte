<script>
	import { keccak256 } from 'viem';

	export let uploadedFile;

	const onFileSelected = (e) => {
		let file = Array.from(e.target.files)[0];
		let reader = new FileReader();
		reader.onload = () => {
			let array = new Uint8Array(reader.result);
			let hash = keccak256(array);
			array = Array.from(array);
			
			uploadedFile = {
				name: file.name,
				lastModified: file.lastModified,
				lastModifiedDate: file.lastModifiedDate,
				size: file.size,
				type: file.type,
				keccak256: hash,
				bytesArray: array,
				bytesArrayLength: array.length,
				file: file,
				description: "",
			};
		};
		reader.readAsArrayBuffer(file);
	};
</script>

<div class="flex items-center justify-center w-full">
	<label
		class="shadow-xl flex flex-col items-center justify-center w-full border-4 border-slate-400 border-dashed rounded-3xl cursor-pointer bg-slate-100 hover:bg-slate-200 hover:border-sky-800"
	>
		<div class="flex justify-center pt-5 pb-6 space-x-8 text-2xl">
			<i class="bi bi-upload" />
			<p class="text-lg text-slate-600 font-bold pt-1">
				Upload a file to verify or publish
			</p>
			<i class="bi bi-upload" />
		</div>
		<input type="file" class="hidden" on:change={(e) => onFileSelected(e)} />
	</label>
</div>
