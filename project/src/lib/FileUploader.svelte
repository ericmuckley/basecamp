<script>

	// keccak256 for [1,2,3]: 0xbc36789e7a1e281436464229828f817d6612f7b477d66591ff96a9e064bcc98a

	import { keccak256 } from 'viem';

	export let fileObject;

	let a = new Uint8Array(...[1,2,3]);
	console.log(a);
	console.log(keccak256(a));

	const onFileSelected = (e) => {
		let file = Array.from(e.target.files)[0];
		let reader = new FileReader();
		reader.onload = () => {
			let array = new Uint8Array(reader.result);
			array = array.slice(0, 3);
			let hash = keccak256(array);
			fileObject = {
				name: file.name,
				lastModified: file.lastModified,
				lastModifiedDate: file.lastModifiedDate,
				size: file.size,
				type: file.type,
				keccak256: hash,
				bytesArray: array,
				bytesArrayLength: array.length
			};
			console.log(fileObject);
		};
		reader.readAsArrayBuffer(file);
	};
</script>

<div class="flex items-center justify-center w-full">
	<label
		class="shadow-xl shadow-indigo-600 flex flex-col items-center justify-center w-full border-2 border-indigo-400 border-dashed rounded-full cursor-pointer hover:bg-indigo-100"
	>
		<div class="flex flex-col items-center justify-center pt-5 pb-6">
			<p class="text-lg text-indigo-600 font-bold">Upload file</p>
		</div>
		<input type="file" class="hidden" on:change={(e) => onFileSelected(e)} />
	</label>
</div>
