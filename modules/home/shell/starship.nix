# Starship prompt configuration
{ config, lib, pkgs, ... }:

{
  # Starship prompt - clean, minimal (based on black-don-os style)
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      # Catppuccin Mocha palette
      add_newline = false;
      
      # Format: environment badges + directory + git branch + conda env on
      # line 1, prompt character on line 2.
      format = lib.concatStrings [
        "$nix_shell"
        "$conda"
        "$directory"
        "$git_branch"
        "$git_status"
        "$git_state"
        "\n"
        "$character"
      ];

      directory = {
        style = "#89b4fa";  # Blue
        truncation_length = 4;
        truncate_to_repo = false;
        format = "[$path]($style) ";
      };

      character = {
        success_symbol = "[›](#cba6f7)";  # Mauve - simple arrow
        error_symbol = "[›](red)";
        vimcmd_symbol = "[‹](#94e2d5)";  # Teal
      };

      nix_shell = {
        format = "[$symbol]($style) ";
        symbol = "[nix]";  # Simple text, no special font needed
        style = "#f5c2e7";  # Pink
      };

      git_branch = {
        symbol = " ";                                       # nerd-font branch glyph (nf-oct-git_branch, U+F418)
        # symbol = " ";                                       # nf-pl-branch â minimal powerline branch
        # symbol = " ";                                       # nf-dev-git â classic git brand logo
        # symbol = " ";                                       # nf-fa-git-alt â modern Font Awesome git
        # symbol = " ";                                       # nf-cod-git-branch â VS Code codicon
        style = "#94e2d5";                                    # Catppuccin teal — vibrant, git-context anchor
        # "on " is a subtle connector word (grey) that makes the git context
        # read naturally: "~/nixos-dotfiles on  main".
        format = "[on ](#7f849c)[$symbol$branch]($style) ";
        truncation_length = 24;
        truncation_symbol = "…";
      };

      conda = {
        style = "#a6e3a1";                            # Green (Catppuccin)
        # Classic conda look: `(envname)`. The `\\(` / `\\)` escapes are needed
        # because unescaped parens in a starship format mean "conditional group".
        format = "[\\($environment\\)]($style) ";
        ignore_base = true;                           # don't show when in `base`
        truncation_length = 2;
      };

      git_status = {
        style = "#fab387";                                    # Catppuccin peach — warm, "stuff to notice"
        # Outer (…) is a conditional group: the whole thing (including brackets)
        # only renders when at least one status/ahead-behind variable is non-empty.
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
        conflicted = "=";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        modified = "!\${count}";
        staged = "+\${count}";
        untracked = "?\${count}";
        stashed = "\$\${count}";
      };

      git_state = {
        style = "#f38ba8";                                  # Red-pink (Catppuccin)
        format = "\\([$state( $progress_current/$progress_total)]($style)\\) ";
      };

      # Identity modules — off (single local machine, not noisy SSH)
      username.disabled = true;
      hostname.disabled = true;
    };
  };
}
