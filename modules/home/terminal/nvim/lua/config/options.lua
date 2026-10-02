-- Options are automatically loaded before lazy.nvim startup
-- Defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

-- Match the editor conventions used across this machine (vim, Zed, .editorconfig)
opt.shiftwidth = 2
opt.tabstop = 2
opt.expandtab = true

-- System clipboard via wl-clipboard (Wayland)
opt.clipboard = "unnamedplus"
