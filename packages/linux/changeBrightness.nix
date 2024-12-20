{ pkgs, lib, ... }:

pkgs.writeShellApplication {
  name = "changeBrightness";
  runtimeInputs = [
    pkgs.brightnessctl
    pkgs.dunst
    pkgs.bc
    pkgs.gnused
  ];
  derivationArgs = {
    meta = {
      platforms = lib.platforms.linux;
    };
  };
  text = ''
    function getProgressString() {
      ITEMS="''$1" # The total number of items(the width of the bar)
      FILLED_ITEM="''$2" # The look of a filled item 
      NOT_FILLED_ITEM="''$3" # The look of a not filled item
      STATUS="''$4" # The current progress status in percent

      # calculate how many items need to be filled and not filled
      FILLED_ITEMS=''$(echo "((''${ITEMS} * ''${STATUS})/100 + 0.5) / 1" | bc)
      NOT_FILLED_ITEMS=''$(echo "''$ITEMS - ''$FILLED_ITEMS" | bc)

      # Assemble the bar string
      msg=''$(printf "%''${FILLED_ITEMS}s" | sed "s| |''${FILLED_ITEM}|g")
      msg=''${msg}''$(printf "%''${NOT_FILLED_ITEMS}s" | sed "s| |''${NOT_FILLED_ITEM}|g")
      echo "''$msg"
    }

    # Arbitrary but unique message id

    brightnessctl set "''$@"

    brightness="''$(brightnessctl get)"
    max="''$(brightnessctl max)"
    current="''$(echo "scale=2;''${brightness}/''${max}*100" | bc)"
    dunstify -h string:x-dunst-stack-tag:volume -a "changeBrightness" -u low -i "display-brightness-symbolic" \
      "Brightness: ''${current}%" "''$(getProgressString 10 "<b> </b>" "　" "''${brightness}")"
  '';
}
