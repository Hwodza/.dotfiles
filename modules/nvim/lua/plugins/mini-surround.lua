return {
  "mini.surround",
  lazy = false,
  after = function()
    require("mini.surround").setup({
      mappings = {
        add = "zs",
        delete = "ds",
        update_n_lines = "gsn",
        find = "gz",
        find_left = "gZ",
        highlight = "gzh",
      },
    })
  end,
}
