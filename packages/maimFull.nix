{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "maimFull";
  runtimeInputs = [
    pkgs.maim
    pkgs.xclip
    pkgs.coreutils-full
  ];
  derivationArgs = {
    meta.platforms = [ "x86_64-linux" ];
  };
  text = ''
    FILENAME="''${HOME}/Pictures/screenshot-''$(date +%Y-%m-%d-%T).png"

    maim "''${FILENAME}" 

    xclip -selection c -t image/png "''${FILENAME}"
  '';
}
