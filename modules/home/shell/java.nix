# Java development environment
# Default: JDK 17 LTS (required for Android / React Native)
{ pkgs, ... }:

{
  # Sets JAVA_HOME and prepends JDK 17 bin to PATH
  programs.java = {
    enable = true;
    package = pkgs.jdk17;
  };
}
