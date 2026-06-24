{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    packages.tmux = inputs.wrapper-modules.wrappers.tmux.wrap {
      inherit pkgs;

      sourceSensible = true;
      secureSocket = true;

      prefix = "C-b";
      terminal = "tmux-256color";
      terminalOverrides = ",xterm-256color:RGB,kitty:RGB,wezterm:RGB,alacritty:RGB";

      baseIndex = 1;
      paneBaseIndex = 1;
      mouse = true;
      modeKeys = "vi";
      statusKeys = "vi";
      vimVisualKeys = true;
      escapeTime = 10;
      historyLimit = 10000;
      allowPassthrough = true;
      disableConfirmationPrompt = false;

      plugins = with pkgs.tmuxPlugins; [
        resurrect
        {
          plugin = continuum;
          after = ["tmuxplugin-resurrect"];
        }
        yank
        vim-tmux-navigator
        tmux-fzf
      ];

      configBefore = ''
        set -g renumber-windows on
        setw -g automatic-rename on
        set -g @continuum-restore 'on'
        set -g @continuum-save-interval '15'
      '';

      configAfter = ''
        bind-key | split-window -h
        bind-key - split-window -v
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R 
      '';
    };
  };
}
