# Flutter SDK (Nix-patched). Dart is bundled — do not install a separate dart package.
# Android toolchain stays with Android Studio under ~/Android/Sdk (android.nix).
{ pkgs, ... }:

{
  home.packages = [ pkgs.flutter ];
}
