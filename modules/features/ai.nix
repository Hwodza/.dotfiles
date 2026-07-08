{
  inputs,
  self,
  ...
}: {
  flake.nixosModules.cloudAI = {
    pkgs,
    config,
    ...
  }: let
    system = pkgs.stdenv.hostPlatform.system;
    unstablePkgs = import inputs.nixpkgs-unstable {
      inherit system;
      config = pkgs.config;
    };
  in {
    imports = [self.nixosModules.opencode];

    environment.systemPackages = with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
      antigravity-cli
      pkgs.codex
    ];
  };

  flake.nixosModules.selfHostedAI = {pkgs, ...}: let
    system = pkgs.stdenv.hostPlatform.system;
    AIpkgs = import inputs.self-hosted-AI-pkgs {
      inherit system;
      config = pkgs.config;
    };
  in {
    environment.systemPackages = [(AIpkgs.llama-cpp.override {cudaSupport = true;})];
  };

  flake.nixosModules.opencode = {
    config,
    pkgs,
    ...
  }: let
    opencodePkg = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode;
    opencodeWrapper = pkgs.writeShellScriptBin "opencode" ''
      export OPENROUTER_ZERO_DATA_RETENTION="$(cat /run/secrets/OpenRouterZeroDataRetention 2>/dev/null || echo "")"
      export OPENROUTER_DATA_RETENTION="$(cat /run/secrets/OpenRouterDataRetention 2>/dev/null || echo "")"
      exec ${opencodePkg}/bin/opencode "$@"
    '';
  in {
    sops.secrets = {
      "OpenRouterZeroDataRetention" = {};
      "OpenRouterDataRetention" = {};
    };

    environment.systemPackages = [opencodeWrapper];

    home-manager.users.${config.preferences.user.name} = {
      xdg.configFile."opencode/opencode.jsonc".text = ''
        {
          "$schema": "https://opencode.ai/config.json",
          "plugin": [
            "opencode-antigravity-auth@latest"
          ],
          "permission": {
            "external_directory": {
              "*": "ask",
              "/nix/store/**": "allow"
            },

            "bash": {
              // 1. Catch-all
              "*": "ask",

              // 2. Standard inspection tools
              "ls *": "allow",
              "tree *": "allow",
              "cat *": "allow",
              "rg *": "allow",
              "grep *": "allow",
              "find *": "allow",

              // 3. Path Traversal Catchers
              "* /*": "ask",
              "* ~*": "ask",
              "* ..*": "ask",

              // 4. Nix Store Bash Exceptions
              "ls /nix/store/*": "allow",
              "tree /nix/store/*": "allow",
              "cat /nix/store/*": "allow",
              "rg */nix/store/*": "allow",
              "grep */nix/store/*": "allow",
              "find /nix/store/*": "allow",

              // 5. Git Read-Only
              "git status*": "allow",
              "git diff*": "allow",
              "git log*": "allow",
              "git show*": "allow",
              "git branch*": "allow",
              "git ls-files*": "allow",
              "git rev-parse*": "allow",
              "git check-ignore*": "allow",

              // 6. Nix Commands
              "nix eval *": "allow",
              "nix build *": "allow",
              "nix flake show *": "allow",
              "nix flake metadata *": "allow",
              "nix search *": "allow",
              "nix-instantiate *": "allow",
              "statix check *": "allow",
              "deadnix *": "allow",
              "alejandra --check *": "allow",
              "nixfmt --check *": "allow",

              // 7. Python Linters & Type Checkers
              "mypy *": "allow",
              "flake8 *": "allow",
              "pylint *": "allow",
              "black --check *": "allow",
              "ruff check *": "allow",
              "ruff check *--fix*": "ask", // Revert to ask if attempting to auto-fix

              // 8. Rust Linters & Checkers
              "cargo check*": "allow",
              "cargo fmt --check*": "allow",
              "cargo clippy*": "allow",
              "cargo clippy *--fix*": "ask", // Revert to ask if attempting to auto-fix

              // 9. Lua Linters
              "luacheck *": "allow",
              "stylua --check *": "allow"
            }
          },
          "provider": {
            "google": {
              "options": {
                "safetySettings": [
                  {
                    "category": "HARM_CATEGORY_HARASSMENT",
                    "threshold": "BLOCK_NONE"
                  },
                  {
                    "category": "HARM_CATEGORY_HATE_SPEECH",
                    "threshold": "BLOCK_NONE"
                  },
                  {
                    "category": "HARM_CATEGORY_SEXUALLY_EXPLICIT",
                    "threshold": "BLOCK_NONE"
                  },
                  {
                    "category": "HARM_CATEGORY_DANGEROUS_CONTENT",
                    "threshold": "BLOCK_NONE"
                  }
                ]
              },
              "models": {
                "antigravity-gemini-3.1-pro": {
                  "name": "Gemini 3 Pro (Antigravity)",
                  "limit": { "context": 1048576, "output": 65535 },
                  "modalities": { "input": ["text", "image", "pdf"], "output": ["text"] }
                },
                "antigravity-gemini-3-flash": {
                  "displayName": "Antigravity Gemini 3 Flash"
                },
                "antigravity-claude-opus-4-6-thinking": {
                  "name": "Claude Opus 4.6 (Antigravity)"
                }
              }
            },
            "openrouter": {
                "options": {
                  "baseURL": "https://openrouter.ai/api/v1",
                }
              },
            "openrouter_zdr": {
                "npm": "@ai-sdk/openai-compatible",
                "name": "OpenRouter (ZDR)",
                "options": {
                  "baseURL": "https://openrouter.ai/api/v1",
                  "apiKey": "{env:OpenRouterZeroDataRetention}"
                }
              },
          }
        }
      '';
    };
  };
}
