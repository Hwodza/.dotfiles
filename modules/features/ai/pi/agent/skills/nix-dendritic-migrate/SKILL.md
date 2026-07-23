---
name: nix-dendritic-migrate
description: Migrates an existing monolithic or loosely-organized Nix/NixOS/home-manager flake configuration into the dendritic pattern (flake-parts + import-tree, one module per concern, features exposed via flake.modules.*). Use whenever the user wants to convert, migrate, refactor, or restructure an existing flake.nix / configuration.nix / home.nix setup into dendritic style, or says things like "split this up", "modularize my config", or "I want to switch to the dendritic pattern". Do not use this for building a brand-new dendritic config from scratch with no existing repo — use the scaffolding skill for that instead.
---

# Nix Dendritic Migrate

Takes an existing flake — usually one big `flake.nix`/`configuration.nix`, or a loose pile of imports — and restructures it into the dendritic pattern: flake-parts + `import-tree`, one file per concern, config exposed through `flake.modules.*` namespaces. This is a mechanical-plus-judgment task: most of the split can be inferred from the existing config's shape, but some calls (what counts as "one concern," what to name a namespace) genuinely need a decision, and those should go back to the user rather than being guessed silently.

## Step 1: Understand what exists before moving anything

Read the current flake fully: what does `flake.nix` output (`nixosConfigurations`, `homeConfigurations`, etc.), what does it import, and how much of the actual configuration lives inline vs. in separate files already. Note anything unusual (custom overlays, non-standard inputs, existing partial modularization) — the migration should preserve these, not flatten them away.

## Step 2: Set up the dendritic scaffolding

Add `flake-parts` and `import-tree` (or the repo's chosen equivalent) as inputs, and rewrite the root `flake.nix` down to something minimal that just wires `import-tree` over a modules directory:

```nix
{
  inputs.flake-parts.url = "github:hercules-ci/flake-parts";
  inputs.import-tree.url = "github:vic/import-tree";

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; }
      (inputs.import-tree ./modules);
}
```

Confirm this matches what the user's ecosystem/other dendritic repos they may be referencing actually use — naming and exact wiring vary.

## Step 3: Split by concern, not by file-that-already-existed

This is the step that needs judgment. Go through the old config section by section and group settings by *what they're for*, not by where they happened to live before:

- A `services.tailscale...` block plus any related `networking.firewall` rules → one `tailscale.nix` module
- Editor/shell/dotfiles settings, wherever they were scattered → one module per tool, or one `shell.nix` if they're small and related
- Anything genuinely host-specific (hostname, disk layout, hardware quirks) → stays host-specific, but still gets its own file rather than living inline in a giant host definition

Assign each new module a namespace (`flake.modules.nixos.*`, `flake.modules.homeManager.*`, etc.) matching what it configures. When a piece of config could reasonably belong to more than one grouping, pick the one that will change together in practice (things edited at the same time for the same reason belong together) and note the call so the user can override it.

## Step 4: Rebuild hosts as thin compositions

Each host should end up as a short list of which modules apply to it, not a redefinition of what those modules contain:

```nix
flake.modules.nixos."laptop" = {
  imports = [
    config.flake.modules.nixos.base
    config.flake.modules.nixos.desktop
    config.flake.modules.nixos.tailscale
  ];
  networking.hostName = "laptop";
};
```

If several hosts share a large common subset, factor that into a shared profile module now rather than leaving duplication for a later cleanup pass — this is the natural point to do it since you're already looking at every host's full config.

## Step 5: Migrate incrementally, verify at each step

Don't do the whole rewrite in one uncheckable jump. After each meaningful chunk (e.g. "modularized nixos-level config," then "modularized home-manager config," then "rebuilt host compositions"), run:

```bash
nix flake check --no-build
nixos-rebuild build --flake .#<host>   # or the darwin/home-manager equivalent
```

and compare the resulting derivation against the pre-migration build where possible (`nix build .#nixosConfigurations.<host>.config.system.build.toplevel` before and after, diff the store paths) to catch accidental behavior changes early rather than at the end.

## Step 6: Report what moved

Give the user a clear before/after map — old location(s) → new module(s) — so they can sanity-check the regrouping decisions, especially any you made a judgment call on. Flag anything you weren't sure how to categorize instead of silently picking a namespace.
