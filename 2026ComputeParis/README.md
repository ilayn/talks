# from hardware import linalg

Slides built with [Slidev](https://sli.dev). Requires Node >= 22.22 and pnpm (the version is pinned in `package.json`).

```sh
pnpm install     # also downloads the headless Chromium used by export
pnpm dev         # live preview at http://localhost:3030 (presenter view at /presenter)
pnpm build       # static site in dist/
pnpm export      # PDF of the deck
pnpm export --format png --output shots   # one PNG per slide
```

- `slides.md` holds the deck
- `styles/index.css` holds global styles, on top of the nord theme
- `components/` holds Vue components, auto-imported into slides
- `public/` holds static assets, served from `/` (e.g. `public/figures/x.svg` becomes `/figures/x.svg`)
- `pnpm-workspace.yaml` holds pnpm settings: dependency overrides and which packages may run install scripts
