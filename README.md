# corinnechin.video

Portfolio site for Corinne Chin, Emmy Award-winning video journalist. Built with [Hugo](https://gohugo.io/).

**Live site:** https://corinnechin.video
**Hosted:** GitHub Pages (`gh-pages` branch serves `public/`)

---

## How the site works

This is a static site with no external theme — all layouts are custom. The homepage shows a hero video reel with a 3-column grid of article thumbnails. Clicking a tile either embeds the video inline (for internal articles) or opens a new tab (for external links).

The interactivity is handled entirely by inline JavaScript in `layouts/partials/footer.html`, using jQuery and HTML5 data attributes on each article tile.

---

## Requirements

- **Hugo 0.128.0+** (extended) — install via Homebrew:
  ```bash
  brew install hugo
  ```
  Native Apple Silicon (arm64) binary. The repo was originally built with Hugo 0.45.1 which has no arm64 support.

---

## Local development

```bash
hugo server
```

Open http://localhost:1313. Hugo will watch for changes and reload automatically.

---

## Deploying

```bash
./deploy.sh
# or with a custom commit message:
./deploy.sh "update about page"
```

`deploy.sh` builds the site, commits everything to `master`, then pushes the contents of `public/` to the `gh-pages` branch (which GitHub Pages serves as the live site).

> **Note:** The `public/` directory is committed to this repo. That's intentional — it's how the deploy script keeps `gh-pages` in sync.

---

## Content

All content lives in `content/`. Articles are Markdown files with TOML frontmatter.

```
content/
  article/        # Main portfolio pieces — these appear on the homepage grid
  poy78/          # "Pictures of the Year" curated section (separate page)
  about.md
  contact.md
  photos.md
```

### Article frontmatter fields

| Field | Description |
|-------|-------------|
| `title` | Article title |
| `description` | Short description shown in the grid tile |
| `image` | Thumbnail path relative to `static/` (e.g. `thumbs/foo.jpg`) |
| `vid` | YouTube embed URL (internal) or external article URL |
| `internal` | `true` = embed video in hero on click; `false` = open in new tab |
| `weight` | Display order in grid (lower = first) |
| `tags` | Taxonomy tags (e.g. `["Editing", "Cinematography"]`) |

---

## Layout structure

```
layouts/
  index.html              # Homepage
  partials/
    header.html           # Nav, fonts, meta
    footer.html           # jQuery, grid JS, click handlers
  article/
    li.html               # Article grid tile (used on homepage + tag pages)
    list.html             # Article section index
  _default/
    single.html           # Generic single page
    list.html             # Used for poy78 section
  taxonomy/
    tag.html              # Tag browse pages (/tags/editing/ etc.)
```

---

## Known issues / cleanup still to do

- Tag frontmatter casing is inconsistent across articles (`"Editing"` vs `"editing"`) — should be normalized
- Article `weight` values are stored as strings (`weight = "3"`) rather than integers in TOML
- Google Analytics ID is Universal Analytics (UA), which was sunset in July 2023 — needs migrating to GA4
- Forestry CMS config (`.forestry/`) is stale — specifies Hugo 0.54.0
