# Zsh shell configuration
{ config, lib, pkgs, ... }:

{
  # Set Zsh as default shell
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    # History settings
    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    # Plugins without Oh My Zsh (lighter weight)
    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
    ];

    # Additional init
    initContent = ''
      # Keybindings
      bindkey "^[[1;5C" forward-word   # Ctrl+Right
      bindkey "^[[1;5D" backward-word  # Ctrl+Left
      
      # Double Esc to add sudo
      sudo-command-line() {
        [[ -z $BUFFER ]] && zle up-history
        [[ $BUFFER != sudo\ * ]] && BUFFER="sudo $BUFFER"
        zle end-of-line
      }
      zle -N sudo-command-line
      bindkey "\e\e" sudo-command-line
    '';
  };
}
