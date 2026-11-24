#!/usr/bin/env bash
# Builds every talk (each folder with a slides.md) into _site/, the static site GitHub Pages serves.
# The Pages workflow runs this on every push to main; run it locally to preview exactly what will go live.
set -euo pipefail
cd "$(dirname "$0")"

rm -rf _site
mkdir -p _site
cp index.html _site/

for slides in */slides.md; do
  talk=$(dirname "$slides")
  out="$PWD/_site/$talk"
  echo "Building $talk"
  # Each talk has its own package.json and lockfile, so an old talk keeps building with the Slidev it was written for.
  # Hash routing (/#/12) lets several decks share one site; --without-notes keeps the speaker notes off the public deck.
  (cd "$talk" && pnpm install --frozen-lockfile && pnpm exec slidev build --base "/talks/$talk/" --router-mode hash --without-notes --out "$out")
  # Only needed for history-mode routing
  rm -f "$out/404.html" "$out/_redirects"
done
