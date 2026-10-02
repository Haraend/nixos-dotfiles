# Raster / vector / CLI image tools — qimgv (apps.nix) stays the viewer
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gimp
    inkscape
    imagemagick # IM7: `magick` (not the old `convert` name)
  ];
}
