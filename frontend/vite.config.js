import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// In development the API (FastAPI, :8000) is reached through this proxy, so there are no CORS issues
// and the same relative URLs work in production behind a reverse proxy.
const api = { target: 'http://localhost:8000', changeOrigin: true }

export default defineConfig({
  plugins: [react()],
  server: { port: 5173, proxy: { '/api': api, '/uploads': api } },
})
