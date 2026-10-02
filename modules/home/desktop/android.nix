# Android development environment
# Android Studio manages its own SDK via the IDE's SDK Manager
# SDK is downloaded to $HOME/Android/Sdk (Android Studio default on Linux)
#
# Flutter doctor / first-run SDK Manager checklist:
#   SDK Platforms → Android API 36
#   SDK Tools → Android SDK Command-line Tools (latest), Build-Tools, Emulator
#   Device Manager → create an AVD (x86_64 Google APIs, API 36)
# Then: flutter doctor && flutter doctor --android-licenses
#
# React Native environment: https://reactnative.dev/docs/set-up-your-environment
# KVM is required for the emulator — user is added to the kvm group in configuration.nix
# USB debugging: systemd 258 uaccess (adb is in modules/nixos/services/adb.nix)
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    android-studio
  ];

  # React Native / Flutter required environment variables
  home.sessionVariables = {
    ANDROID_HOME = "$HOME/Android/Sdk";
    ANDROID_SDK_ROOT = "$HOME/Android/Sdk"; # Legacy alias, still required by some tools
  };

  # Add Android SDK tool directories to PATH
  home.sessionPath = [
    "$HOME/Android/Sdk/emulator"
    "$HOME/Android/Sdk/platform-tools"
    "$HOME/Android/Sdk/cmdline-tools/latest/bin"
  ];
}
