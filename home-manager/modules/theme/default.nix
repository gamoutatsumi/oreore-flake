{ localFlake, withSystem }:
{ lib, ... }:
{
  imports = [
    ./wallpaper.nix
    (lib.importApply ./tinty.nix { inherit localFlake; })
  ];
}
