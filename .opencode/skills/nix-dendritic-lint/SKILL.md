---
name: nix-dendritic-lint
description: Reviews a Nix flake written in the dendritic pattern (flake-parts + import-tree, one file per concern, config exported via flake.modules.*) for anti-patterns and structural drift. Use this whenever the user asks to review, audit, lint, or clean up their Nix config, mentions "anti-patterns" in their flake, asks "does this look right" about a module, or wants a second opinion before merging changes to a dendritic Nix repo. Also trigger on requests like "check my nixos config for smells" or "is this module in the right place" even if the user doesn't say "dendritic" explicitly.
---

# Nix Dendritic Lint

Reviews a dendritic-pattern Nix flake for anti-patterns: places where a module has drifted from the pattern's core idea, which is that **each file describes one concern, self-contained, and is auto-discovered rather than manually wired**.

The dendritic pattern is a community convention, not a single spec, so implementations vary (different repos use `flake.modules.homeManager` vs `flake.modules.home`, different directory layouts, etc.). Don't assume a rigid canonical schema — infer the repo's own conventions first, then check for internal consistency against them. The goal is catching real problems, not enforcing an opinion the user's repo doesn't hold.

## Step 1: Learn the repo's actual conventions before judging it

Before flagging anything, establish:
- Where `import-tree` (or equivalent) is called, and which directory it scans
- What namespaces the repo uses under `flake.modules.*` (or wherever config is exported) — list them, don't assume
- How hosts/profiles are assembled from those namespaces (e.g. a `nixosConfigurations.<host>` picking up `flake.modules.nixos.*`)
- Whether `perSystem` is used for system-specific things (packages, devShells, checks)

Grep for `import-tree`, `flake.modules`, `perSystem`, and `nixosConfigurations`/`homeConfigurations`/`darwinConfigurations` to build this picture quickly rather than reading every file.

## Step 2: Run the mechanical checks

These catch a lot cheaply before any pattern-specific reasoning:

```bash
nix flake check --no-build
statix check .
deadnix .
```

Report anything they surface plainly — say what was found and where, not just that a tool "found issues."

## Step 3: Check for dendritic-specific anti-patterns

Walk the module tree looking for these. For each hit, cite the file and explain the concrete downside, not just "this violates the pattern":

- **Manual import lists.** A file with an `imports = [ ./foo.nix ./bar.nix ]` list where those files are already reachable by `import-tree`. This defeats the auto-discovery the whole pattern is built on, and means two things now have to be kept in sync by hand.
- **Namespace reaching.** A module in one namespace (say `homeManager`) directly referencing another namespace's config (`config.flake.modules.nixos...`) instead of expressing a real dependency through options, or simply not needing to know about it. This is the dendritic equivalent of a layering violation.
- **Organized by target instead of by concern.** A `hosts/laptop.nix` file that piles up unrelated settings (networking, editor, shell, secrets) because it's grouped by *machine* rather than by *feature*. The dendritic idea is the opposite: one file for "tailscale," which may itself touch nixos + home-manager + a shared option, is easier to reason about than "everything laptop needs."
- **Orphaned modules.** A file defines something under `flake.modules.*` that no host or profile ever consumes. Either it's dead code, or it's wired in some way the auto-discovery convention doesn't expect (worth flagging either way).
- **Hardcoded systems.** Literal `"x86_64-linux"` strings scattered through modules instead of using `perSystem` or a systems helper. This breaks silently on other architectures and duplicates a decision that should live in one place.
- **Options without types or descriptions** on anything meant to be reused across hosts (as opposed to a one-off `config` block, where this matters less).
- **Secrets not colocated.** Secrets wiring (`sops-nix`, `agenix`, etc.) defined far from the module that actually needs the secret, making it hard to tell what depends on what.
- **God files.** A single file doing several unrelated things — if it's not obviously "one concern," ask whether it should be split. Don't flag small, genuinely cohesive files just for being long.

## Step 4: Report

Lead with a short summary (how many files reviewed, roughly how healthy the tree looks), then list findings grouped by severity:

```markdown
## Summary
Reviewed N modules across <namespaces found>. <one line overall read>

## Blocking (breaks builds / silently wrong)
- `path/to/file.nix`: <what> — <why it matters>

## Worth fixing (drift from the pattern, no immediate breakage)
- `path/to/file.nix`: <what> — <why it matters>

## Nitpicks
- ...
```

Don't invent findings to fill out sections — an empty "Blocking" section is a fine outcome. If the repo genuinely follows the pattern cleanly, say so plainly instead of manufacturing nitpicks.
