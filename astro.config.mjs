import { defineConfig } from "astro/config";
import mdx from "@astrojs/mdx";
import sitemap from "@astrojs/sitemap";
import icon from "astro-icon";

import playformInline from "@playform/inline";

// https://astro.build/config
export default defineConfig({
  site: "https://bwc9876.dev",
  compressHTML: true,
  integrations: [mdx(), icon({ iconDir: "src/assets/icons" }), sitemap(), playformInline()],
  image: { dangerouslyProcessSVG: true, },
  markdown: {
    shikiConfig: {
      theme: "catppuccin-mocha"
    }
  },
  // fonts: [
  //   {
  //     name: "Maple Mono",
  //     fallbacks: ["monospace"],
  //     cssVariable: "--font-maple-mono",
  //     provider: fontProviders.npm({ remote: false }),
  //     options: { package: "@fontsource/maple-mono", file: "latin.css", },
  //   },
  //   {
  //     name: "Charis SIL",
  //     cssVariable: "--font-charis",
  //     provider: fontProviders.npm({ remote: false }),
  //     options: { package: "@fontsource/charis-sil", file: "latin.css", },
  //   }
  // ],
  vite: {
    css: {
      transformer: "lightningcss",
      lightningcss: { drafts: { customMedia: true } }
    },
    build: {
      cssMinify: "lightningcss"
    }
  },
  experimental: {
    rustCompiler: true
  }
});
