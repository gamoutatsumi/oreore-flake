{
  importApply,
  tintySchemes,
}:
{ ... }:
{
  imports = [
    ./wallpaper.nix
    (importApply ./tinty.nix { inherit tintySchemes; })
  ];
}
