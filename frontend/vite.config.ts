import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

const proxyTarget = process.env.VITE_PROXY_TARGET ?? "http://127.0.0.1:4000";
const usePolling = process.env.CHOKIDAR_USEPOLLING === "true";
const hmrHost = process.env.VITE_HMR_HOST ?? "localhost";
const hmrPort = Number(process.env.VITE_HMR_PORT ?? 5173);

export default defineConfig({
  plugins: [react()],
  server: {
    host: "0.0.0.0",
    port: 5173,
    strictPort: true,
    watch: {
      usePolling,
      interval: usePolling ? 1000 : undefined
    },
    hmr: {
      host: hmrHost,
      port: hmrPort,
      clientPort: hmrPort
    },
    proxy: {
      "/api": {
        target: proxyTarget,
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, "")
      }
    }
  }
});
