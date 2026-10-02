# Android Debug Bridge (`adb` / `fastboot`).
# systemd 258 applies uaccess rules automatically — no programs.adb, no adbusers.
{ pkgs, ... }:

{
  environment.systemPackages = [ pkgs.android-tools ];
}
