import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

const base = process.env.DOCS_SITE_BASE ?? '/'

export default defineConfig({
  base,
  plugins: [react()],
  build: {
    outDir: 'dist',
    emptyOutDir: true,
    sourcemap: false,
    cssCodeSplit: false,
    rollupOptions: {
      output: {
        entryFileNames: 'assets/[name].js',
        chunkFileNames: 'assets/[name].js',
        assetFileNames: 'assets/[name].[ext]',
      },
    },
  },
})
