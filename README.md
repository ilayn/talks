# Talks

Slides from my talks, served with GitHub Pages at https://ilayn.github.io/talks/. Each folder is one talk, built with [Slidev](https://sli.dev).

- [from hardware import linalg](https://ilayn.github.io/talks/2026ComputeParis/), Paris, November 2026

## Working on a talk

```sh
cd 2026ComputeParis
pnpm install
pnpm dev        # live preview at http://localhost:3030 (presenter view with notes at /presenter)
```

## Publishing

Every push to `main` runs the [Pages workflow](.github/workflows/pages.yml): it builds each talk with [build.sh](build.sh) and publishes the result. The built site is never committed. Run `./build.sh` to build the same site into `_site/` locally.

To add a talk, create a folder with its own `slides.md` and `package.json`, and add it to the list above and to `index.html`.
