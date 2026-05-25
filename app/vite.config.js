import { defineConfig } from "vite";

export default defineConfig(async () => ({
  root: "./src",
  publicDir: "images",
  clearScreen: false,
  server: {
    port: 1420,
    strictPort: true,
  },
  envPrefix: ["VITE_", "TAURI_"],
  build: {
    outDir: "../dist",
    emptyOutDir: true,
  },
}));
