import adapter from '@sveltejs/adapter-node';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	kit: {
		// Use adapter-node for SSR with standalone Node.js server
		adapter: adapter({
			out: 'build'
		})
	}
};

export default config;
