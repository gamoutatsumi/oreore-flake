{ pkgs, lib, ... }:

pkgs.writeShellApplication {
  name = "changeVolume";
  runtimeInputs = [
    pkgs.wireplumber
    pkgs.dunst
    pkgs.bc
    pkgs.gnused
    pkgs.gnugrep
    pkgs.gawk
    pkgs.coreutils-full
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

    # Arbitrary but unique message id

    if [[ "''$1" == "mute" ]]; then
      wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    else
      wpctl set-volume @DEFAULT_AUDIO_SINK@ "''$@"
    fi

    volume="''$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | sed "s/Volume: //g")"
    if [[ ''${volume} == '0.00' || "''${volume}" == *"[MUTED]"* ]]; then
        # Show the sound muted notification
        dunstify -h string:x-dunst-stack-tag:volume -a "changeVolume" -u low -i "audio-volume-muted-symbolic" "Volume muted"
    else
        # Show the volume notification
        volume_percentage=''$(echo "''${volume} * 100" | bc | awk '{print int($1)}')
        dunstify -h string:x-dunst-stack-tag:volume -a "changeVolume" -u low -i "audio-volume-high-symbolic" \
        "Volume: ''${volume_percentage}%" "''$(getProgressString 10 "<b> </b>" "　" "''${volume_percentage}")"
    fi
  '';
}
