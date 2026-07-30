hl.window_rule({
  name = "suppressevent_maximi",
  match = {
    class = ".*",
  },
  suppress_event = "maximize",
})

hl.window_rule({
  name = "nofocus",
  match = {
    class = "^$",
    title = "^$",
    xwayland = 1,
    fullscreen = 0,
  },
  no_focus = true,
})

hl.window_rule({
  match = { class = "kitty" },
  opacity = "0.75",
  -- xray = true,
  no_blur = true,
})

hl.window_rule({
  name = "workspace_special_di",
  match = {
    class = "^(discord)$",
  },
  workspace = "special:discord",
})

hl.window_rule({
  name = "workspace_special_sp",
  match = {
    class = "^(spotify)$",
  },
  workspace = "special:spotify",
})

hl.window_rule({
  name = "workspace_special_ya",
  match = {
    class = "^(kitty-yazi)$",
  },
  opacity = "0.8 0.8",
  xray = true,
  -- no_blur = true,
  workspace = "special:yazi",
})

hl.window_rule({
  name = "workspace_special_bt",
  match = {
    class = "^(kitty-btop)$",
  },
  opacity = "0.8",
  xray = true,
  -- no_blur = true,
  workspace = "special:btop",
})
