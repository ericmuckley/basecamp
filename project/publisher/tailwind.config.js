/** @type {import('tailwindcss').Config} */
export default {
	content: ['./src/**/*.{html,js,svelte,ts}'],
	darkMode: 'class',
	theme: {
		extend: {
			colors: {
				extralightgray: 'var(--extralightgray)',
				lightgray: 'var(--lightgray)',
				gray: 'var(--gray)',
				darkgray: 'var(--darkgray)',
				dark0: 'var(--dark0)',
				dark1: 'var(--dark1)',
				dark2: 'var(--dark2)',
				dark3: 'var(--dark3)',
				bright: 'var(--bright)',
				bright2: 'var(--bright2)',
				accent: 'var(--accent)',
				link: 'var(--link)',
				link2: 'var(--link2)',
				linklight: 'var(--linklight)'
			}
		}
	},
	plugins: []
};
