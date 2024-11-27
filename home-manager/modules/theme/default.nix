{
  localFlake,
  withSystem,
  importApply,
}:
{ lib, ... }:
{
  imports = [
    ./wallpaper.nix
    (importApply ./tinty.nix { inherit localFlake; })
  ];
}
