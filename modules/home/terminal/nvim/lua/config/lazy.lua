-- Bootstrap lazy.nvim, then hand off to LazyVim + our plugin specs.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Leader must be set before lazy.nvim loads
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

require("lazy").setup({
  spec = {
    -- LazyVim core + its bundled plugin set (imported first, per LazyVim's
    -- ordering check), then our overrides from lua/plugins/*.lua
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "plugins" },
  },
  defaults = { lazy = false, version = false },
  install = { colorscheme = { "catppuccin", "habamax" } },
  checker = { enabled = true },
  -- Home Manager deploys ~/.config/nvim read-only from the Nix store, so the
  -- lockfile must live beside the plugin checkouts in the data dir instead.
  lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
  ui = { border = "rounded" },
})
