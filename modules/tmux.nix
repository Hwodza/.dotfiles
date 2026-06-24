{
  inputs,
  ...
}: {
  perSystem = {
    pkgs,
    ...
  }: {
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

      configBefore = ''
        set -g renumber-windows on
        setw -g automatic-rename on
      '';

      configAfter = ''
        bind-key | split-window -h
        bind-key - split-window -v
      '';
    };
  };
}
