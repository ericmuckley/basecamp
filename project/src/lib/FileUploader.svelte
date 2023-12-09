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
			console.log(uploadedFile);
		};
		reader.readAsArrayBuffer(file);
	};
</script>

<div class="flex items-center justify-center w-full">
	<label
		class="shadow-xl shadow-indigo-600 flex flex-col items-center justify-center w-full border-2 border-indigo-400 border-dashed rounded-full cursor-pointer hover:bg-indigo-100"
	>
		<div class="flex flex-col items-center justify-center pt-5 pb-6">
			<p class="text-lg text-indigo-600 font-bold">Upload a file to verify or publish</p>
		</div>
		<input type="file" class="hidden" on:change={(e) => onFileSelected(e)} />
	</label>
</div>
