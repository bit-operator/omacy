-- Colorscheme follows `theme <name>` (reads ~/.config/omachy/current/theme.env); Tokyo Night otherwise.
local function omachy_colorscheme()
  local f = io.open(vim.fn.expand("~/.config/omachy/current/theme.env"), "r")
  if f then
    for line in f:lines() do
      local name = line:match('^NVIM_COLORSCHEME="?([^"]+)"?')
      if name then
        f:close()
        return name
      end
    end
    f:close()
  end
  return "tokyonight-night"
end

return {
  { "folke/tokyonight.nvim", opts = { style = "night" } },
  { "catppuccin/nvim", name = "catppuccin", lazy = true },
  { "ellisonleao/gruvbox.nvim", lazy = true },
  { "rebelot/kanagawa.nvim", lazy = true },
  { "LazyVim/LazyVim", opts = { colorscheme = omachy_colorscheme() } },
}
