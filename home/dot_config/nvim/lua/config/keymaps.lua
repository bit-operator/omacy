-- LazyVim defaults: https://www.lazyvim.org/keymaps
local map = vim.keymap.set

map("n", "<leader>fy", function()
  local path = vim.fn.expand("%:.")
  vim.fn.setreg("+", path)
  vim.notify("Copied " .. path)
end, { desc = "Yank relative file path" })
