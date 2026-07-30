-- Static monitor configuration (monitors.lua) calls hl.monitor(...) directly.
-- We need to know which monitors were configured that way so workspaces.lua
-- can pre-register workspace rules for them even before they're plugged in.
-- To do that, we temporarily wrap hl.monitor while requiring the given
-- module, record every configured output, then put the original back.

return function(module_name)
  local configured = {}
  local original_monitor = hl.monitor

  hl.monitor = function(config)
    if config and config.output then
      table.insert(configured, { name = config.output, id = #configured })
    end
    return original_monitor(config)
  end

  require(module_name)

  hl.monitor = original_monitor

  return configured
end
