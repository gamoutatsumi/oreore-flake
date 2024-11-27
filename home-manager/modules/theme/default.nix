{
  localFlake,
  withSystem,
  importApply,
  tintySchemes,
}:
{ lib, ... }:
{
  imports = [
    ./wallpaper.nix
    (importApply ./tinty.nix { inherit localFlake tintySchemes; })
  ];
}
