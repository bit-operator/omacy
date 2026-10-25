-- Set by dot-push on remotes without internet. Read from env: specs are parsed before options.lua.
local offline = vim.env.OMACY_OFFLINE == "1"

return {
  -- C-h/j/k/l moves across nvim splits and tmux panes alike (pairs with tmux.conf).
  {
    "christoomey/vim-tmux-navigator",
    cmd = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" },
    keys = {
      { "<C-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Window/pane left" },
      { "<C-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Window/pane down" },
      { "<C-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Window/pane up" },
      { "<C-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Window/pane right" },
    },
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
  },

  -- Offline remotes: don't try to download LSPs/tools; LazyVim falls back to binaries on $PATH.
  { "mason-org/mason.nvim", enabled = not offline },
  { "mason-org/mason-lspconfig.nvim", enabled = not offline },
}
