local M = {
  setup = function()
    vim.g.gruvbox_material_background = 'hard'
    vim.g.gruvbox_material_enable_italic = 1
    vim.g.gruvbox_material_transparent_background = 0
    vim.cmd [[colorscheme gruvbox-material]]
  end,
}

return M

