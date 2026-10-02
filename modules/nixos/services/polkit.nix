{ ... }:

{
  security.polkit = {
    enable = true;
    # Required for GUI elevation (e.g. rpi-imager). Store pkexec is not setuid.
    enablePkexecWrapper = true;
  };
}
