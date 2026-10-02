return {
  -- Catppuccin Mocha tracks the Stylix wallpaper-derived palette
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      term_colors = true,
    },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
}
