# CLAUDE.md — ctc (corinnechin.video)

## What this site is

A Hugo static site for video journalist Corinne Chin (corinnechin.video). It is a portfolio site with a hero video reel and a grid of article thumbnails. Clicking an article tile either embeds an iframe video in the hero area (internal articles) or opens a new tab (external links). There is no external Hugo theme — all layouts are custom.

## The core problem

**This site was built for Hugo 0.45.1 (released 2018).** That version has no pre-built binary for Apple Silicon (arm64). Running `hugo` on an M1/M2/M3 Mac requires Rosetta 2 emulation or building from source, and the site may still fail due to deprecated APIs used across the templates.

The last `public/` rebuild commit was June 2024, suggesting someone managed to build it (likely via Rosetta or a CI environment), but local development on Apple Silicon is essentially broken without workarounds.

## Why you can't just upgrade Hugo

Several deprecated or removed APIs are in use that will cause build failures on any modern Hugo version:

| File | Deprecated usage | Modern replacement |
|------|------------------|--------------------|
| `layouts/index.html:16` | `.Data.Pages` | `.Pages` or `site.Pages` |
| `layouts/article/li.html:13` | `relLangURL` | `relURL` (single-language site) |
| `config.toml:7-9` | `contentdir`, `layoutdir`, `publishdir` keys | These are now implicit or set via CLI flags |
| `config.toml:11` | `cononifyurls` (also a typo of `canonifyurls`) | `canonifyURLs` |

Additionally, Hugo's internal template system, Pygments-based syntax highlighting config, and taxonomy defaults have all shifted significantly between 0.45 and current versions (0.140+).

## Directory structure

```
config.toml          # Hugo config (old-style keys, see above)
content/
  article/           # 30+ portfolio pieces (TOML frontmatter)
  poy78/             # "Pictures of the Year" subsection (YAML frontmatter)
  about.md
  contact.md
  photos.md
layouts/
  index.html         # Homepage: hero video + article grid
  _default/          # single, list, li, summary, aboutme
  article/           # list, li, index
  partials/          # header, footer, video, tags, list-2
  taxonomy/          # tag.html
static/
  css/               # style.css (custom grid, responsive)
  js/3wrap.js
  thumbs/            # Article thumbnail images
  img/               # Hero video (mp4)
public/              # Built output — committed to repo (deployed directly)
.forestry/           # Forestry CMS config (preview set to Hugo 0.54.0)
```

## Key frontmatter fields (content/article/*.md)

- `vid` — YouTube embed URL or external URL
- `internal` — boolean; if true, video is embedded in the hero; if false, opens new tab
- `image` — relative path to thumbnail in `static/thumbs/`
- `weight` — display order in grid

## How the site works (important for upgrades)

The interactivity lives entirely in `layouts/partials/footer.html` as inline JavaScript:
- jQuery 3.1.0 + Modernizr 2.8.3 are loaded from CDNs
- Clicking `.item` tiles reads `data-vid`, `data-internal`, `data-title`, `data-desc` attributes
- Internal items inject an iframe into `#hero`; external items call `window.open()`
- A scroll listener adds/removes `.fixed-header` on the nav
- History API pushState is wired up but the `swapPhoto` function is incomplete (the XHR is opened but never sent — this appears to be dead/broken code)

## Deployment

The `public/` directory is committed to the repo. The site appears to be served directly from this directory (no Netlify/Vercel config was found). The Forestry CMS `.forestry/settings.yml` specifies Hugo 0.54.0 for previews, which is also outdated.

---

## Changes made (Hugo 0.45.1 → 0.128.0 migration)

The following fixes were applied to make the site build and run correctly on Hugo 0.128.0 (native arm64):

| File | Change |
|------|--------|
| `layouts/partials/header.html` | `.Hugo.Generator` → `hugo.Generator` (removed in 0.128) |
| `layouts/index.html` | `.Data.Pages` + `where "Section"` → `{{ with .Site.GetPage "/article" }}{{ range .Pages.ByWeight }}` — the old pattern returned the section page itself, not its children |
| `layouts/article/list.html` | `.Data.Pages` + `where "Section"` → `range .Pages.ByWeight` (called in section context, so `.Pages` is already scoped) |
| `layouts/article/li.html` | `relLangURL` → `relURL` |
| `layouts/_default/li.html` | `relLangURL` → `relURL` |
| `config.toml` | Removed `contentdir`, `layoutdir`, `publishdir` (now implicit); fixed typo `cononifyurls` → `canonifyURLs` |

### Key discovery: `.Data.Pages` + `where "Section"` behavior change

In Hugo 0.45, `{{ range where .Data.Pages "Section" "article" }}` on the homepage returned all article content pages. In Hugo 0.128, this returns only the section page itself (Kind="section", Title="Articles", no params). The fix is to use `.Site.GetPage "/article"` to get the section, then range over `.Pages` which returns only the section's children.

### Known remaining issues

- The `weight` frontmatter in all articles is stored as a **string** (`weight = "23"`) rather than an integer. Hugo parses this correctly for now, but it may cause ordering issues and should be cleaned up.
- `layouts/article/index.html` is a separate template from `article/list.html` and may have its own issues (not yet audited).
- `_default/summary.html` and `_default/aboutme.html` have not been audited for deprecated APIs.
- The Forestry CMS config (`.forestry/settings.yml`) still specifies Hugo 0.54.0 for previews and is stale.
- Google Analytics ID is UA (Universal Analytics), which was sunset July 2023.

### Still to do

- [ ] Audit remaining layout files for deprecated APIs
- [ ] Fix `weight` frontmatter values from strings to integers across all article files
- [ ] Investigate and fix tag duplication issue — some articles use `"Editing"` (capitalized) and others use `"editing"` (lowercase); Hugo normalizes these to the same taxonomy term but the display behavior may cause apparent duplicates
