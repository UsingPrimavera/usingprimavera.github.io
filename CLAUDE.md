# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Technical documentation and blog site for Oracle Primavera products (P6, Unifier) and Oracle Analytics Server. Built with Jekyll 4.4.1 and the Just the Docs 0.10.1 theme. Two content areas: structured documentation (Diataxis) and a blog.

## Build Commands

```bash
# Install dependencies
bundle install

# Build the site
bundle exec jekyll build

# Build for production (enables analytics, etc.)
JEKYLL_ENV=production bundle exec jekyll build

# Serve locally with live reload (http://localhost:4000)
bundle exec jekyll serve --livereload

# Create new content (jekyll-compose)
bundle exec jekyll draft "Title"                       # Create a draft
bundle exec jekyll publish _drafts/filename.md         # Publish a draft
bundle exec jekyll post "Title"                        # Create a post directly

# HTML validation (development only)
bundle exec htmlproofer _site --disable-external --ignore-urls "/localhost/"
```

## Publish Workflow

The site builds locally and pushes pre-built HTML to the `master` branch, which GitHub Pages serves. GitHub Pages never runs Jekyll — it only serves static files. This means all gems (including `jekyll-paginate-v2`) are fully supported.

```bash
# When ready to publish a release:
cd /home/barrie/src/work/usingprimavera.com

# 1. Clean previous build
bundle exec jekyll clean

# 2. Build production site
JEKYLL_ENV=production bundle exec jekyll build

# 3. Publish to master (from inside _site/, which tracks master branch)
cd _site
git add .
git commit -m "Release: YYYY-MM-DD"
git push origin master

# GitHub Pages serves master as the live site at usingprimavera.com
```

## Content Architecture

Two distinct content areas:

### 1. Documentation area (Just the Docs)

Follows the [Diataxis](https://diataxis.fr) framework:

| Collection | Directory | Purpose |
|------------|-----------|---------|
| Tutorials | `_tutorials/` | Learning-oriented, step-by-step guides |
| How-To Guides | `_how-to-guides/` | Task-oriented practical instructions |
| Explanations | `_explanations/` | Understanding-oriented conceptual content |
| References | `_references/` | Information-oriented lookup documentation |

Drafts go in `_drafts/` until ready for publication.

### 2. Blog area (custom layouts)

Posts go in `_posts/` using the standard Jekyll naming convention: `YYYY-MM-DD-title.md`.

The blog index is at `/blog/` with pagination (10 posts per page).

## Front Matter Schema

### Documentation content (Diataxis collections)

```yaml
---
title: "Your Title Here"
date: 2026-MM-DD HH:MM +0000
last_modified_date: 2026-MM-DDTHH:MM:SS+00:00
nav_order: 1              # Controls sidebar position within collection
product: p6               # One of: p6 | unifier | oas | power-query
# diataxis_type is set by defaults (tutorial | how-to | explanation | reference)
# layout is set by defaults (default) — do not set manually
---
```

### Blog posts (`_posts/`)

```yaml
---
title: "Your Blog Post Title"
date: 2026-MM-DD HH:MM +0000
categories:
  - how-to           # or: tutorial | explanation | reference | opinion | learning-path
tags:
  - p6
  - scheduling
description: "One sentence description for SEO and post preview."
image: /assets/images/your-image.png    # Open Graph image (optional)
product: p6          # One of: p6 | unifier | oas | power-query
# layout: post — set by defaults
# author: Barrie Callender — set by defaults
---
```

## Key Configuration

- **Theme:** just-the-docs 0.10.1 (docs area only)
- **Blog layouts:** custom `_layouts/post.html` and `_layouts/blog.html`
- **Color scheme:** dark (configured in `_config.yml`)
- **Mermaid diagrams:** Supported (v11.9.0)
- **Search:** Enabled with `Ctrl/Cmd + K` shortcut
- **RSS feed:** `/feed.xml` (jekyll-feed)
- **Sitemap:** `/sitemap.xml` (jekyll-sitemap)
- **Pagination:** jekyll-paginate-v2, 10 posts per page
- **Source branch:** `source`
- **Published branch:** `master` (pre-built HTML)
- **Live site:** https://usingprimavera.com

## Plugin Suite

| Gem | Purpose |
|-----|---------|
| just-the-docs 0.10.1 | Documentation theme |
| jekyll-compose | Draft/post/publish CLI commands |
| jekyll-feed | RSS feed at /feed.xml |
| jekyll-seo-tag | Meta tags, Open Graph, Twitter Card |
| jekyll-sitemap | sitemap.xml |
| jekyll-paginate-v2 | Blog pagination |
| html-proofer (dev) | Link and HTML validation |

## Data Files (`_data/`)

| File | Purpose |
|------|---------|
| `subjects.yml` | Product taxonomy (p6, unifier, oas, power-query) |
| `navigation.yml` | Top-level nav links (Documentation, Blog, About) |
| `learning_paths.yml` | Learning paths across Diataxis quadrants (Phase 5) |

## Mermaid Diagrams

Use fenced code blocks with `mermaid` language identifier:

````markdown
```mermaid
flowchart LR
    A[Start] --> B[End]
```
````

## Git Workflow

- Source branch is `source` (not `main` or `master`)
- Published branch is `master` (pre-built `_site/` contents)
- Commit prefixes: `feat:`, `fix:`, `upd:`, `new:`
- The `_site/` directory is gitignored on `source` — it tracks `master` as a separate git worktree/nested repo
