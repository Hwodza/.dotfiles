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

  flake.nixosModules.selfHostedAI = {
    pkgs,
    config,
    ...
  }: let
    system = pkgs.stdenv.hostPlatform.system;
    AIpkgs = import inputs.self-hosted-AI-pkgs {
      inherit system;
      config = pkgs.config;
    };
    llama-cpp =
      (AIpkgs.llama-cpp.override {
        cudaSupport = true;
        rocmSupport = false;
        metalSupport = false;
        # Enable BLAS for optimized CPU layer performance (OpenBLAS)
        # This is crucial for models using split-mode or CPU offloading
        blasSupport = true;
      }).overrideAttrs
      (oldAttrs: {
        # Enable native CPU optimizations for massively better CPU performance
        # This enables AVX, AVX2, AVX-512, FMA, etc. for your specific CPU
        # NOTE: This is intentionally opposite of nixpkgs (which uses -DGGML_NATIVE=off
        # for reproducible builds). We sacrifice portability for faster CPU layers.
        cmakeFlags =
          (oldAttrs.cmakeFlags or [])
          ++ [
            "-DGGML_NATIVE=ON"
          ];
        # Disable Nix's NIX_ENFORCE_NO_NATIVE which strips -march=native flags
        # See: https://github.com/NixOS/nixpkgs/issues/357736
        # See: https://github.com/NixOS/nixpkgs/pull/377484 (intentionally contradicts this)
        preConfigure = ''
          export NIX_ENFORCE_NO_NATIVE=0
          ${oldAttrs.preConfigure or ""}
        '';
      });
  in {
    environment.systemPackages = [
      llama-cpp
      AIpkgs.llama-swap
    ];
    sops.secrets."searx" = {};
    services = {
      searx = {
        enable = true;
        # Utilize the maintained SearXNG fork rather than the deprecated Searx
        package = pkgs.searxng;
        redisCreateLocally = true;

        settings = {
          server = {
            # Bind exclusively to the local loopback interface for security
            bind_address = "127.0.0.1";
            port = 8888;
            # The secret key should ideally be managed via sops-nix in production
            secret_key = "$(cat ${config.sops.secrets."searx".path})";
            image_proxy = true;
            method = "GET";
          };
          search = {
            # The JSON format is strictly required for MCP server parsing
            formats = ["html" "json"];
            safe_search = 1;
            autocomplete = "duckduckgo";
            ban_time_on_fail = 5;
          };
          engines = [
            {
              name = "google";
              disabled = false;
              weight = 2;
            }
            {
              name = "duckduckgo";
              disabled = false;
              weight = 1;
            }
            {
              name = "bing";
              disabled = false;
              weight = 1;
            }
            {
              name = "arch linux wiki";
              disabled = false;
            }
            {
              name = "github";
              disabled = false;
            }
          ];
          outgoing = {
            request_timeout = 5.0;
            max_request_timeout = 15.0;
            pool_connections = 100;
          };
        };
      };

      llama-swap = {
        enable = true;
        package = pkgs.llama-swap; # or your custom-flags override, if you still need one

        settings = {
          healthCheckTimeout = 1800;
          models = {
            "qwen2.5:0.5b" = {
              cmd = ''
                ${llama-cpp}/bin/llama-server
                --hf-repo bartowski/Qwen2.5-0.5B-Instruct-GGUF:Q4_K_M
                --port ''${PORT}
                --ctx-size 0
              '';
            };
            "qwen3.6-35b-a3b" = {
              cmd = ''
                ${llama-cpp}/bin/llama-server
                --port ''${PORT}
                --hf-repo unsloth/Qwen3.6-35B-A3B-GGUF:Q4_K_M
                -ngl 999
                --n-cpu-moe 35
                --no-mmap
                --mlock
                --cache-type-k q4_0
                --cache-type-v q4_0
                -c 131072
              '';
            };
          };
        };
      };
    };

    # Layered on top of whatever the module already generates for this unit.
    systemd.services.llama-swap.serviceConfig = {
      Environment = [
        "PATH=/run/current-system/sw/bin"
        "LD_LIBRARY_PATH=/run/opengl-driver/lib:/run/opengl-driver-32/lib"
        "LLAMA_CACHE=/var/lib/llama-swap/cache"
        "HF_HOME=/var/lib/llama-swap/cache"
      ];
      # Only uncomment/add these if you actually need a fixed user instead of
      # whatever the module defaults to — see caveat below.
      # User = "basnijholt";
      # Group = "users";
      StateDirectory = "llama-swap";
    };
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

    environment.systemPackages = [
      pkgs.nodejs_22
      opencodeWrapper
    ];

    home-manager.users.${config.preferences.user.name} = {
      xdg.configFile."opencode/opencode.jsonc".text = ''
        {
          "$schema": "https://opencode.ai/config.json",
          "plugin": [
            "opencode-antigravity-auth@latest"
          ],
          "mcp": {
            "searxng-research": {
              "type": "local",
              "command": [
                "npx",
                "-y",
                "mcp-searxng"
              ],
              "enabled": true,
              "environment": {
                "SEARXNG_URL": "http://localhost:8888",
                "SEARXNG_MAX_RESULTS": "6",
                "SEARXNG_MAX_RESULT_CHARS": "500",
                "URL_READ_MAX_CHARS": "4000",
                "CACHE_TTL_MS": "86400000",
                "URL_READ_MAX_CONTENT_LENGTH_BYTES": "5242880",
                "USER_AGENT": "NixOS-Agentic-Research/1.0"
              }
            }
          },
          "agent": {
            "thinker": {
              "description": "Deliberate reasoning agent that thinks through problems step-by-step before answering",
              "mode": "subagent",
              "model": "local-llama/qwen3.6-35b-a3b",
              "temperature": 0.1,
              "steps": 30,
              "permission": {
                "edit": "deny",
                "bash": "deny",
                "websearch": "deny",
                "webfetch": "deny"
              },
              "prompt": "You are a deep thinking agent. For every problem, follow this process:\n1. Restate the problem clearly\n2. Break it into sub-problems\n3. Analyze each sub-problem step by step\n4. Consider alternative approaches\n5. Identify potential issues or edge cases\n6. Synthesize your analysis into a clear, well-reasoned conclusion\nShow your complete reasoning before giving the final answer."
            },
            "researcher": {
              "description": "Conducts thorough web research using SearXNG, synthesizes findings into comprehensive reports with citations",
              "mode": "subagent",
              "model": "local-llama/qwen3.6-35b-a3b",
              "temperature": 0.3,
              "steps": 40,
              "permission": {
                "websearch": "allow",
                "webfetch": "allow",
                "edit": "deny",
                "bash": "deny"
              },
              "prompt": "You are a research agent. You have access to web search and URL reading tools via SearXNG. For each research task:\n1. Search broadly with multiple queries, then narrow down\n2. Read and summarize key sources\n3. Cross-reference information across multiple sources\n4. Identify gaps in knowledge and search again if needed\n5. Produce a well-organized report with clear section headings\nAlways cite your sources with URLs and be transparent about source reliability."
            },
            "architect": {
              "description": "Hybrid planner that analyzes codebases, researches best practices online, and produces structured restructuring plans",
              "mode": "subagent",
              "model": "local-llama/qwen3.6-35b-a3b",
              "temperature": 0.2,
              "steps": 50,
              "permission": {
                "websearch": "allow",
                "webfetch": "allow",
                "read": "allow",
                "glob": "allow",
                "grep": "allow",
                "edit": "ask",
                "bash": "deny"
              },
              "prompt": "You are an architect agent specializing in codebase restructuring. Follow this structured process:\n\n## Phase 1: Analyze\n1. Read the codebase structure (directories, files, dependencies)\n2. Identify pain points: coupling, duplication, inconsistent patterns, outdated practices, missing abstractions\n3. Document current architecture and dependencies\n\n## Phase 2: Research\n1. Use SearXNG to find best practices relevant to the tech stack\n2. Research design patterns, module organization strategies, and modern approaches\n3. Cross-reference industry standards with the specific context\n\n## Phase 3: Plan\nProduce a step-by-step restructuring plan that includes:\n- Proposed directory/module structure\n- Module boundaries and dependency graph\n- Migration steps (atomic, reversible, low-risk first)\n- Benefits of each proposed change\n- Potential risks and mitigations\n- Estimated effort for each phase\n\nPresent your findings clearly with concrete examples from the codebase and cited sources from research."
            }
          },
          "permission": {
            "external_directory": {
              "*": "ask",
              "/nix/store/**": "allow"
            },
            "searxng-research_*": "allow",

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
            "local-llama": {
              "npm": "@ai-sdk/openai-compatible",
              "name": "Llama Swap (Local)",
              "options": {
                "baseURL": "http://127.0.0.1:8080/v1",
                "apiKey": "sk-no-key-required"
              },
              "models": {
                "qwen3.6-35b-a3b": {
                  "name": "qwen3.6-35b-a3b"
                }
              }
            },
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
