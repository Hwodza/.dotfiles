---
name: nix-dendritic-docs
description: Generates or refreshes documentation (README, docs site, per-module summaries) describing a Nix flake configuration written in the dendritic pattern (flake-parts + import-tree, one module per file, features exposed via flake.modules.*). Use whenever the user asks to document, write a README or overview for, or explain the structure of a dendritic Nix repo, or asks something like "summarize what all these modules do" or "write up how my hosts are composed."
---

# Nix Dendritic Docs

Generates documentation for a dendritic-pattern flake that stays true to what the repo actually contains, rather than hand-written prose that drifts out of date the next time a module is added or renamed. The core idea: derive as much as possible from the modules themselves (option descriptions, file names, namespace structure) and only add prose for things code can't say on its own — why a decision was made, how pieces relate.

## Step 1: Inventory the tree

Walk the module tree and build a table of: file path, namespace(s) it defines (`flake.modules.nixos.foo`, `flake.modules.homeManager.foo`, etc.), and a one-line summary of what it configures. Pull the summary from an existing top-of-file comment if the module has one; otherwise infer it from what the module actually sets, and note that it was inferred rather than author-provided (so the user can correct anything you got wrong).

Also inventory: what hosts/profiles exist, and which modules each one pulls in.

## Step 2: Extract structured info, don't just prose-summarize

Where modules define `options` with `description` fields, pull those directly rather than re-describing them in your own words — they're already meant to be documentation, and duplicating them by hand is exactly the kind of docs that drift. Where a module has no options (it's just `config`), a short human summary is fine.

## Step 3: Decide the shape of the output

Match what the user asked for:
- **README** → a single markdown file: brief intro, how to build/switch a host, a module table (path → namespace(s) → summary), and a short "how hosts are composed" section
- **Docs site / multi-file** → split by namespace or by domain, mirroring the repo's own organization, with an index page linking to each
- **Just a summary in chat** → skip file creation, answer conversationally

Default to README-in-repo unless the user's phrasing or repo already implies something bigger (e.g. an existing `docs/` directory with more structure).

## Step 4: Write it

Structure for a README-style doc:

```markdown
# <repo name>

<1-3 sentence description of what this config manages>

## Hosts
| Host | Modules |
|---|---|
| laptop | base, desktop, tailscale, neovim |
| ... | ... |

## Modules
| Module | Namespace(s) | What it does |
|---|---|---|
| `modules/tailscale.nix` | nixos | Enables Tailscale, ... |
| ... | ... | ... |

## Building
\`\`\`bash
nixos-rebuild switch --flake .#<host>
\`\`\`
```

Keep prose sections short — the tables are the documentation; prose is for anything that genuinely needs explaining (an unusual choice, a gotcha, a manual step that isn't captured in the modules themselves).

## Step 5: Flag drift risk

If any module has no doc-comment and no `description` fields to draw from, say so rather than silently inventing confident-sounding prose — note it as "summary inferred from config, not module-provided" so the user knows to sanity-check it, and suggest adding a description if the module is meant to be reused.
