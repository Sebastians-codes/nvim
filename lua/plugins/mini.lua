-- Mini collection: surround for adding/removing surroundings
return {
  'echasnovski/mini.nvim',
  config = function()
    -- Setup mini.surround for surroundings
    require('mini.surround').setup {
      -- Use default mappings
    }
  end,
}