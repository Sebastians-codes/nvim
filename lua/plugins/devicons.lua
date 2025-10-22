return {
  {
    'nvim-tree/nvim-web-devicons',
    config = function()
      require('nvim-web-devicons').setup {
        override = {},
        default = true,
        color_icons = false,
        override_by_filename = {},
        override_by_extension = {},
      }

      vim.schedule(function()
        local devicons = require 'nvim-web-devicons'
        local icons = devicons.get_icons()

        for name, icon in pairs(icons) do
          devicons.set_icon {
            [name] = {
              icon = icon.icon,
              color = '#9A9D9A',
              name = name,
            },
          }
        end
      end)
    end,
  },
}
