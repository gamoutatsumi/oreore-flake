{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "launchPolybar";
  runtimeInputs = [
    pkgs.procps
    pkgs.gnugrep
    pkgs.gawk
    pkgs.coreutils
    pkgs.iproute2
    pkgs.polybarFull
  ];
  derivationArgs = {
    meta.platforms = [ "x86_64-linux" ];
  };
  text = ''
    while pgrep -u ''$UID -x polybar > /dev/null; do sleep 0.1; done

    i=0
    while true; do
      if [[ ''$i -eq 10 ]]; then
        break
      fi
      DEFAULT_INTERFACE=''$(ip route | grep '^default' | awk '{print ''$5}' | head -n1)
      export DEFAULT_INTERFACE
      if [[ -n ''$DEFAULT_INTERFACE ]]; then
        break
      fi
      ((i++)) || true
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
