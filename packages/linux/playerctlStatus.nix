{ pkgs, lib, ... }:
pkgs.writeShellApplication {
  name = "playerctlStatus";
  runtimeInputs = [
    pkgs.playerctl
    pkgs.gnused
    pkgs.gawk
  ];
  derivationArgs = {
    meta = {
      platforms = lib.platforms.linux;
    };
  };
  text = ''
    play_icon=
    pause_icon=
    prev_icon=
    next_icon=
    stop_icon=

    playerctl -F metadata --format "{{ duration(position) }} / {{ duration(mpris:length) }} {{ artist }} - title({{ title }}) %{A1:playerctl previous -p {{ playerName }}:}''$prev_icon%{A} %{A1:playerctl stop -p {{ playerName }}:}''$stop_icon%{A} %{A1:playerctl play-pause -p {{ playerName }}:}{{ status }}%{A} %{A1:playerctl next -p {{ playerName }}:}''$next_icon%{A} %{-o}" -i mpd 2>/dev/null \
      | sed -u -r "s/Playing/''$pause_icon/g; s/(Paused|Stopped)/''$play_icon/g" \
      | awk -v len=15 '{ STITLE = false; TITLE = gensub(".*?title\\((.*?)\\).*?", "\\1", "g", ''$0); if (length(TITLE) > len) STITLE = substr(TITLE, 1, len-3) "..."; if (STITLE) {print gensub("title\\((.*?)\\)", STITLE, "g", ''$0)} else {print gensub("title\\((.*?)\\)", TITLE, "g", ''$0)} fflush() }'
  '';
}
