# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Technical documentation site for Oracle Primavera products (P6, Gateway, Unifier) and Oracle Analytics Publisher. Built with Jekyll and the Just The Docs theme.

## Build Commands

```bash
# Install dependencies
bundle install

# Build the site
bundle exec jekyll build

# Serve locally with live reload (http://localhost:4000)
bundle exec jekyll serve

# Create new content
bundle exec jekyll draft "Title"       # Create a draft
bundle exec jekyll publish _drafts/filename.md  # Publish a draft
bundle exec jekyll post "Title"        # Create a post directly
```

## Content Architecture

Content follows the [Diataxis](https://diataxis.fr) documentation framework with four collections:

| Collection | Directory | Purpose |
|------------|-----------|---------|
| Tutorials | `_tutorials/` | Learning-oriented, step-by-step guides |
| How-To Guides | `_how-to-guides/` | Task-oriented practical instructions |
| Explanations | `_explanations/` | Understanding-oriented conceptual content |
| References | `_references/` | Information-oriented lookup documentation |

Drafts go in `_drafts/` until ready for publication.

## Content Frontmatter

All content files require YAML frontmatter:

```yaml
---
layout: post          # or 'home', 'default', 'page'
title: Your Title
date: 2025-01-22 10:00 +0000
last_modified_date: 2025-01-22T10:00:00+00:00
nav_order: 1          # Controls sidebar ordering
---
```

## Key Configuration

- **Theme:** just-the-docs 0.10.1
- **Color scheme:** dark (configured in `_config.yml`)
- **Mermaid diagrams:** Supported (v11.9.0)
- **Search:** Enabled with `Ctrl/Cmd + K` shortcut
- **Main branch:** `source`
- **Deployment:** GitHub Pages to usingprimavera.com

## Mermaid Diagrams

Use fenced code blocks with `mermaid` language identifier:

````markdown
```mermaid
flowchart LR
    A[Start] --> B[End]
```
````

## Git Workflow

- Main branch is `source` (not `main` or `master`)
- Commit prefixes used: `Updated:`, `upd:`, `new:`, `feat:`, `fix:`
