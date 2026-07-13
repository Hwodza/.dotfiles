{
  inputs,
  self,
  ...
}: {
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
}
