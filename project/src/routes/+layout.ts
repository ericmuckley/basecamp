/*
This is needed to prevent server-side rendering of the layout.
In the layout is rednered server-side, there is no 'window'
object obtained from the browser, so injected web3 providers like
MetaMask and Coinbase wallet cannot be used.
*/
export const ssr = false;