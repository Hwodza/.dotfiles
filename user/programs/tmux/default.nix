{
  pkgs,
  ...
}:
{
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    keyMode = "vi";
    plugins = with pkgs.tmuxPlugins; [
      better-mouse-mode
      vim-tmux-navigator
      yank
      sensible
      nord
      tmux-which-key
    ];
    extraConfig =
      # bash
      ''
        # Begin window count at 1
        set -g base-index 1



        # set vi-mode
        set-window-option -g mode-keys vi
        set -g status-keys vi
        setw -g mode-keys vi

        # vi keybindings
        bind h select-pane -L
        bind j select-pane -D
        bind k select-pane -U
        bind l select-pane -R

        # Stay in same directory when split
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"

        # Force true colors
        set-option -ga terminal-overrides ",*:Tc"

        set-option -g mouse on
        set-option -g focus-events on

        # Make it so escape forwards instantly for vim
        set -sg escape-time 0

        # Control b, control c, to change the working directory
        bind C-c command-prompt -p "New working directory:" "attach -c '%%'"

        bind-key "T" run-shell "sesh connect \"$(
          sesh list --icons | fzf-tmux -p 80%,70% \
            --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
            --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
            --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
            --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
            --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
            --preview-window 'right:55%' \
            --preview 'sesh preview {}'
        )\""
        set -g allow-passthrough on
      '';
  };
}
