---
name: nix-dendritic-compose
description: Designs or audits how hosts (nixosConfigurations, homeConfigurations, darwinConfigurations) are composed from reusable profile and leaf modules in a Nix flake written in the dendritic pattern (flake-parts + import-tree, flake.modules.* namespaces). Use whenever the user wants to set up a new host or machine, compose a host from profiles, figure out what's shared between machines, or asks things like "why does my laptop config duplicate my desktop's" or "help me structure profiles for base/desktop/server."
---

# Nix Dendritic Compose

Helps design or audit the *composition layer* of a dendritic flake — the layer above individual modules, where hosts get built up from a small set of reusable profiles plus host-specific leaf config. Individual modules being well-formed doesn't guarantee this layer is healthy; a repo can have perfectly clean per-concern modules and still have hosts that duplicate each other or profiles that silently conflict.

## Step 1: Map what exists

List every host/output the flake defines (`nixosConfigurations.*`, `homeConfigurations.*`, `darwinConfigurations.*`) and, for each, exactly which modules and profiles it imports. If the repo already has a profile layer (e.g. `base`, `desktop`, `server`, `laptop`), note what each profile itself pulls in — profiles are just modules that group other modules, so the same "what does this actually consume" question applies recursively.

## Step 2: For designing a new host

Ask what the new host is (or infer from the user's description) and work out its composition as a short, explicit list, favoring existing profiles over hand-picking leaf modules:

```nix
flake.modules.nixos."new-host" = {
  imports = with config.flake.modules.nixos; [
    base
    desktop
    tailscale
  ];
  networking.hostName = "new-host";
  # host-specific bits only: hostname, hardware, disk layout
};
```

If no profile fits and the host needs a genuinely new combination that other hosts are likely to want too, suggest creating the profile rather than repeating the module list inline — that's exactly the duplication this layer exists to prevent. If it's a one-off combination unlikely to be reused, inline is fine; don't force premature abstraction.

## Step 3: For auditing existing hosts

Compare hosts pairwise (or as a full matrix for >3 hosts) on which modules/profiles each pulls in, and separately, whether any host defines config *inline* that duplicates what another host gets from a module. The second check matters more — two hosts independently writing near-identical `services.foo.settings` blocks inline is the real problem, not just "they both use module X" (which is fine, that's the point of modules).

Report duplication as a concrete diff, not a vague "these are similar":

```markdown
`laptop` and `desktop` both inline the same 8-line `programs.git` config.
Neither pulls it from a shared module. Candidate for a `git` module both can import.
```

## Step 4: Check for profile conflicts

When a host imports multiple profiles, check whether any of them set the same option to different values — flake-parts/NixOS module merging will error loudly for conflicting non-mergeable options, but list-like or attrset options can merge silently in ways the user didn't intend (e.g. two profiles both enabling different, incompatible display managers where only the last one "wins" unexpectedly). Flag these even if the build currently succeeds, since silent-but-surprising merges are worse than loud errors.

## Step 5: Report

Give a composition table (host → profiles → any host-specific leaf config) plus a short list of findings: duplication to factor out, profile combinations that conflict, and — if relevant — a suggested new profile boundary. Keep suggestions proportional to actual duplication found; don't propose restructuring three hosts into five profiles over one shared line of config.
