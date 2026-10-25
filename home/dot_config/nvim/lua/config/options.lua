-- LazyVim defaults: https://www.lazyvim.org/configuration/general
local opt = vim.opt

opt.scrolloff = 8
opt.relativenumber = true
opt.wrap = false
opt.colorcolumn = "120"

-- Over SSH, copy through OSC 52 (lands in the Mac clipboard via Ghostty/tmux).
-- Paste stays local to nvim's registers — use Cmd+V in the terminal to paste from the Mac.
if vim.env.SSH_CONNECTION or vim.env.SSH_TTY then
  local osc52 = require("vim.ui.clipboard.osc52")
  local function paste()
    return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
  end
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = paste, ["*"] = paste },
  }
  opt.clipboard = "unnamedplus"
end
