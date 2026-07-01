# Android development environment
# Android Studio manages its own SDK via the IDE's SDK Manager
# SDK is downloaded to $HOME/Android/Sdk (Android Studio default on Linux)
#
# After first launch, open Android Studio and:
#   1. SDK Manager → install Android SDK Platform, Build-Tools, Emulator
#   2. AVD Manager → create a virtual device for testing
#
# React Native environment: https://reactnative.dev/docs/set-up-your-environment
# KVM is required for the emulator — user is added to the kvm group in configuration.nix
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    android-studio
    android-tools  # Standalone adb, fastboot, mkbootimg
  ];

  # React Native required environment variables
  home.sessionVariables = {
    ANDROID_HOME = "$HOME/Android/Sdk";
    ANDROID_SDK_ROOT = "$HOME/Android/Sdk";  # Legacy alias, still required by some tools
  };

  # Add Android SDK tool directories to PATH
  home.sessionPath = [
    "$HOME/Android/Sdk/emulator"
    "$HOME/Android/Sdk/platform-tools"
  ];
}
