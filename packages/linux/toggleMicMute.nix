{ pkgs, lib, ... }:
pkgs.writeShellApplication {
  name = "toggleMicMute";
  runtimeInputs = [
    pkgs.pulseaudio
    pkgs.gnugrep
    pkgs.gawk
    pkgs.gnused
    pkgs.coreutils
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

    # changeVolume
    pactl set-source-mute @DEFAULT_SOURCE@ toggle

    # Arbitrary but unique message id

    default_source="''$(LANG=C LC_ALL=C pactl info | grep "^Default Source" | awk '{print ''$3}')"
    volume="''$(LANG=C LC_ALL=C pactl list sources | grep "Name: ''${default_source}" -A 10 | grep '^[[:space:]]Volume:' | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')"
    mute="''$(LANG=C LC_ALL=C pactl list sources | grep "Name: ''${default_source}" -A 10 | grep 'Mute:' | sed 's/^[[:space:]]//' | cut -d " " -f 2)"
    if [[ ''$volume == 0 || "''$mute" == "yes" ]]; then
        # Show the sound muted notification
        dunstify -h string:x-dunst-stack-tag:volume -a "changeVolume" -u low -i "microphone-sensitivity-muted-symbolic" "Volume muted"
    else
        # Show the volume notification
        dunstify -h string:x-dunst-stack-tag:volume -a "changeVolume" -u low -i "microphone-sensitivity-high-symbolic" \
        "Volume: ''${volume}%" "''$(getProgressString 10 "<b> </b>" "　" "''${volume}")"
    fi
  '';
}
