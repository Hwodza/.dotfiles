-- Small, static values shared across the config. Keeping them in one place
-- means every module agrees on what "the mod key" or "how many workspaces"
-- means, instead of each file redefining its own copy.

return {
  terminal = os.getenv("TERMINAL") or "kitty",
  app_launcher = "rofi -show combi",
  session_launcher = "rofi -show session",
  main_mod = "ALT",
  caps_mod = "MOD2",
  workspace_count = 10,
}
