local theme = require("lib.theme")

-- All plain hl.config() sections are merged into a single call: Hyprland
-- treats them as independent tables anyway, so there's no reason to make
-- six separate round trips through hl.config.
hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 0,
    border_size = 2,
    ["col.active_border"] = theme.active_border,
    ["col.inactive_border"] = theme.inactive_border,
    resize_on_border = true,
    allow_tearing = false,
    layout = "scrolling",
  },

  decoration = {
    rounding = 10,
    active_opacity = 1,
    inactive_opacity = 1,
    shadow = {
      enabled = true,
      range = 4,
      render_power = 3,
      color = theme.shadow,
    },
    blur = {
      enabled = true,
      size = 3,
      passes = 2,
      noise = 0.023,
      contrast = 0.9,
      vibrancy = 0.1696,
      new_optimizations = true,
    },
  },

  animations = {
    enabled = true,
  },

  scrolling = {
    fullscreen_on_one_column = true,
    column_width = 1.0,
    focus_fit_method = 1,
    follow_min_visible = 0.0,
  },

  binds = {
    window_direction_monitor_fallback = false,
  },

  misc = {
    force_default_wallpaper = 0,
    disable_hyprland_logo = false,
  },
})

hl.layer_rule({
  name = "blur_noctalia_bar",
  match = {
    namespace = "^noctalia-bar-content-.*",
  },
  blur = true,
  xray = true,
})

hl.animation({
  leaf = "workspaces",
  enabled = true,
  speed = 5,
  bezier = "default",
  style = "slidevert",
})
