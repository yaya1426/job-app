import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.js'],
            refresh: true,
        }),
    ],
    server: {
        https: true,
    },
    build: {
        // Ensure assets are served over HTTPS
        manifest: true,
        outDir: 'public/build',
        rollupOptions: {
            output: {
                assetFileNames: 'assets/[name]-[hash][extname]',
            },
        },
    },
});
