---
name: nix-dendritic-scaffold
description: Generates a new, correctly-shaped module file for a Nix flake configuration written in the dendritic pattern (flake-parts + import-tree, one file per concern, features exposed via flake.modules.*). Use this whenever the user wants to add a module, create a module for something, set up a new service/feature, or extend an existing dendritic config with new functionality — e.g. "add tailscale", "add a home-manager module for neovim", "set up syncthing on my desktop". Trigger even if the user doesn't say the word "module" explicitly, as long as they're adding a feature to a dendritic Nix repo.
---

# Nix Dendritic Scaffold

Creates a new module file in a dendritic-pattern flake, shaped correctly from the start: right namespace, right file location, right skeleton, and actually wired in — not left orphaned because `import-tree` picked it up but nothing consumes it.

The reason this needs its own step rather than "just write a nix file" is that in the dendritic pattern the *location and namespace* of a file carries meaning that a normal Nix file wouldn't have — get that wrong and the module is invisible to the hosts that need it, or visible in the wrong place.

## Step 1: Read the existing repo before writing anything

Don't guess the repo's conventions — look at 2-3 existing modules first to learn:
- The directory layout (flat `modules/`? grouped by namespace? grouped by domain?)
- The exact namespace names in use under `flake.modules.*` (e.g. `nixos`, `homeManager`, `darwin` — names vary by repo)
- Whether a single file commonly defines config for more than one namespace at once (a hallmark of dendritic style: one file for "the tailscale concern" that includes both the nixos service and any home-manager pieces, rather than splitting by target)
- How a host actually picks up a module — e.g. does `nixosConfigurations.<host>` reference `flake.modules.nixos.<name>` directly, or through a `flake.modules.nixos.default`/profile aggregation?

## Step 2: Decide the shape of the new module

Ask (or infer from context) what the feature touches:
- **System-level only** (a systemd service, a NixOS option) → belongs in the `nixos` namespace (or repo's equivalent)
- **User-level only** (dotfiles, a home-manager program) → belongs in the `homeManager` namespace
- **Both** → still one file if the repo's convention is "one concern per file," defining both namespaces' config in the same module. This is often the most idiomatic dendritic shape, not an exception to it.
- **Cross-system tooling** (a devShell, a package, a formatter) → belongs under `perSystem`, not hardcoded to one system string

If genuinely ambiguous after checking the repo, ask the user directly rather than guessing — getting the namespace wrong is the single most disruptive mistake here.

## Step 3: Write the module

Match the exact style of neighboring modules (attribute style, how `lib`/`pkgs` are destructured, comment conventions). A minimal shape looks like:

```nix
{ config, lib, pkgs, ... }:
{
  flake.modules.nixos.tailscale = { pkgs, ... }: {
    services.tailscale.enable = true;
    # ...
  };
}
```

or, for a module touching two namespaces at once:

```nix
{
  flake.modules.nixos.neovim = { pkgs, ... }: {
    environment.systemPackages = [ pkgs.neovim ];
  };

  flake.modules.homeManager.neovim = { pkgs, ... }: {
    programs.neovim.enable = true;
    # user-level config here
  };
}
```

Give any option a type and a `description` if it's meant to be reused across hosts — skip this ceremony for a one-off `config`-only module where there's nothing to reuse.

## Step 4: Wire it in — don't leave it orphaned

A module that only exists under `flake.modules.*` does nothing on its own; it has to be picked up somewhere. Check how the repo does this (common patterns: a host directly lists the module name, or a "profile" file aggregates several modules and hosts reference the profile) and make the equivalent edit — e.g. add `tailscale` to the laptop host's module list, or to the shared `desktop` profile if it should apply broadly.

Tell the user explicitly which file(s) you touched to do the wiring, since it's easy to create a module and forget this step, and the failure mode (module exists, does nothing) is silent.

## Step 5: Verify

Run a build/check scoped to what changed rather than the whole flake if the repo is large:

```bash
nix flake check --no-build
nix build .#nixosConfigurations.<host>.config.system.build.toplevel --dry-run
```

Report the result plainly, including any error output.
