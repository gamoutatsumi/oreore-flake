{ pkgs, lib, ... }:
pkgs.writeShellApplication {
  name = "launchPolybar";
  runtimeInputs = [
    pkgs.procps
    pkgs.gnugrep
    pkgs.gawk
    pkgs.coreutils
    pkgs.iproute2
    pkgs.polybarFull
    (pkgs.callPackage ./xmonadpropread.nix { })
  ];
  derivationArgs = {
    meta = {
      platforms = lib.platforms.linux;
    };
  };
  text = ''
    i=0
    echo "Starting Polybar..."
    while true; do
      if [[ ''$i -eq 10 ]]; then
        echo "loop count over 10. exit."
        break
      fi
      DEFAULT_INTERFACE="''$(ip route | grep '^default' | awk '{print ''$5}' | head -n1)"
      if [[ -n ''$DEFAULT_INTERFACE ]]; then
        export DEFAULT_INTERFACE
        echo "found default interface"
        break
      fi
      i=$((i + 1))
      sleep 1
    done
    IFS=''$'\n'
    for m in ''$(polybar --list-monitors); do
      if grep -q primary <(echo "''${m}"); then
        MONITOR=''$(echo "''${m}" | cut -d":" -f1) polybar --reload main >/dev/null 2>&1 &
      else
        MONITOR=''$(echo "''${m}" | cut -d":" -f1) polybar --reload sub >/dev/null 2>&1 &
      fi
    done
  '';
}
