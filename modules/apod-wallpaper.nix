{
  config,
  pkgs,
  ...
}: {
  flake.homeModules.apod-wallpaper = {
    config,
    pkgs,
    ...
  }: let
    # TODO currently the script assumes all photos are jpg
    apod-wallpaper = pkgs.writeShellApplication {
      name = "apod-wallpaper";
      runtimeInputs = with pkgs; [curl jq awww kitty matugen systemd];
      text = ''
        WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

        # Secret is provided as a file path via the systemd service
        APOD_KEY="$(cat "$APOD_KEY_FILE")"

        echo "Downloading APOD data"
        json=$(curl -sf "https://api.nasa.gov/planetary/apod?api_key=$APOD_KEY") || {
          echo "Failed to fetch APOD data" >&2
          exit 1
        }

        date=$(echo "$json"         | jq -r '.date')
        explanation=$(echo "$json"  | jq -r '.explanation')
        media_type=$(echo "$json"   | jq -r '.media_type')
        title=$(echo "$json"        | jq -r '.title')
        url=$(echo "$json"          | jq -r '.url')
        thumbnail_url=$(echo "$json" | jq -r '.thumbnail_url // empty')

        TodayDir="$WALLPAPER_DIR/$date"

        echo "Checking media type"
        if [ "$media_type" != "image" ]; then
          if [ -z "$thumbnail_url" ]; then
            echo "Media type is not image and no thumbnail_url provided, exiting" >&2
            exit 1
          else
            echo "Media type is not image, but thumbnail_url exists — downloading thumbnail"
            download_url="$thumbnail_url"
          fi
        else
          echo "Media type is image, will download"
          download_url="$url"
        fi

        echo "Checking for today's dir"
        if [ ! -d "$TodayDir" ]; then
          echo "$TodayDir doesn't exist."
          echo "Creating $TodayDir."
          mkdir -p "$TodayDir"
          echo "$TodayDir created"

          echo "Downloading image"
          curl -s "$download_url" --output "$TodayDir/$title.jpg"

          echo "Downloading explanation"
          echo "$explanation" > "$TodayDir/$title-explanation"

          echo "Creating symlink to wallpaper"
          ln -sf "$TodayDir/$title.jpg" "$WALLPAPER_DIR/wallpaper"

          echo "Setting wallpaper and theme"
          set-wallpaper "$TodayDir/$title.jpg"
        fi
      '';
    };
  in {
    # Declare the sops secret — the raw API key will be written to a
    # managed file at runtime that only your user can read.
    sops.secrets.NASA_APOD = {};

    # Make the script available on PATH if you ever want to run it manually.
    home.packages = [apod-wallpaper];

    # ── Systemd user service ──────────────────────────────────────────────────
    systemd.user.services.apod-wallpaper = {
      Unit = {
        Description = "Download NASA Astronomy Picture of the Day and set as wallpaper";
        # Ensures the network is up before running (adjust target to suit your setup)
        After = ["network-online.target"];
        Wants = ["network-online.target"];
      };
      Service = {
        Type = "oneshot";

        # Pass the sops secret file path as an env var rather than its contents,
        # so the key is never stored in the unit file or the journal.
        Environment = [
          "APOD_KEY_FILE=${config.sops.secrets.NASA_APOD.path}"
        ];

        ExecStart = "${apod-wallpaper}/bin/apod-wallpaper";

        # Restart on failure with a short backoff, in case of transient network issues.
        Restart = "on-failure";
        RestartSec = "60s";
      };
    };

    # ── Systemd user timer (runs once per day) ────────────────────────────────
    systemd.user.timers.apod-wallpaper = {
      Unit = {
        Description = "Daily NASA APOD wallpaper update";
      };
      Timer = {
        # Fire at 12:05 AM Eastern time every day (system timezone is already America/New_York).
        OnCalendar = "*-*-* 00:05:00";

        # Also run shortly after every boot, in case the machine was off at 12:05.
        # 2 minutes gives the network time to come up before the script runs.
        OnBootSec = "2min";

        # Persistent = true means: if the 12:05 window was missed entirely
        # (machine off, suspended, etc.), run it as soon as the timer next
        # activates rather than waiting until the following night.
        Persistent = true;
      };
      Install = {
        WantedBy = ["timers.target"];
      };
    };
  };
}
