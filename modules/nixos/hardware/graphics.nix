# Intel GPU + VA-API hardware video acceleration (ThinkPad T14)
{ pkgs, ... }:

{
  # Graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver   # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver   # LIBVA_DRIVER_NAME=i965 (older but good fallback)
      libva-vdpau-driver
      libvdpau-va-gl
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-vaapi-driver
    ];
  };

  # Environment variables to force Intel driver
  environment.sessionVariables = { 
    LIBVA_DRIVER_NAME = "iHD"; 
  };
}
