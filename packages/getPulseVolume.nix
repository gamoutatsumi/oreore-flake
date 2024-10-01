{ pkgs, lib, ... }:

pkgs.writeShellApplication {
  name = "getPulseVolume";
  runtimeInputs = [
    pkgs.pulseaudio
    pkgs.dunst
    pkgs.bc
    pkgs.gnused
    pkgs.gnugrep
    pkgs.gawk
    pkgs.coreutils-full
  ];
  derivationArgs = {
    meta.platforms = [ "x86_64-linux" ];
  };
  text = ''
    default_sink="''$(LANG=C LC_ALL=C pactl info | grep "^Default Sink" | awk '{print ''$3}')"
    default_sink_index="''$(LC_ALL=C pacmd list-sinks | grep -E -i 'index:|name:' | grep '\*' | sed 's/^[[:space:]]*//' | cut -f 3 -d ' ')"
    mute="''$(LANG=C LC_ALL=C pactl list sinks | grep "Sink #''${default_sink_index}" -A 10 | grep 'Mute:' | sed 's/^[[:space:]]//' | cut -d " " -f 2)"
    volume="''$(LANG=C LC_ALL=C pactl list sinks | grep '^[[:space:]]Volume:' | grep "''${default_sink}" | sed -e 's,.* \([0-9][0-9]*\)%.*,\1,')"
    bars=''$([[ ''$mute = "no" ]] && echo "''${volume}" | awk '{print ''$0 / 10}' || echo MM)

    case ''$bars in
        0) bar='----------' ;;
        0.1) bar='----------' ;;
        0.2) bar='----------' ;;
        0.3) bar='----------' ;;
        0.4) bar='----------' ;;
        0.5) bar='/---------' ;;
        0.6) bar='/---------' ;;
        0.7) bar='/---------' ;;
        0.8) bar='/---------' ;;
        0.9) bar='/---------' ;;
        1) bar='/---------' ;;
        1.1) bar='/---------' ;;
        1.2) bar='/---------' ;;
        1.3) bar='/---------' ;;
        1.4) bar='/---------' ;;
        1.5) bar='//--------' ;;
        1.6) bar='//--------' ;;
        1.7) bar='//--------' ;;
        1.8) bar='//--------' ;;
        1.9) bar='//--------' ;;
        2) bar='//--------' ;;
        2.1) bar='//--------' ;;
        2.2) bar='//--------' ;;
        2.3) bar='//--------' ;;
        2.4) bar='//--------' ;;
        2.5) bar='///-------' ;;
        2.6) bar='///-------' ;;
        2.7) bar='///-------' ;;
        2.8) bar='///-------' ;;
        2.9) bar='///-------' ;;
        3) bar='///-------' ;;
        3.1) bar='///-------' ;;
        3.2) bar='///-------' ;;
        3.3) bar='///-------' ;;
        3.4) bar='///-------' ;;
        3.5) bar='////------' ;;
        3.6) bar='////------' ;;
        3.7) bar='////------' ;;
        3.8) bar='////------' ;;
        3.9) bar='////------' ;;
        4) bar='////------' ;;
        4.1) bar='////------' ;;
        4.2) bar='////------' ;;
        4.3) bar='////------' ;;
        4.4) bar='////------' ;;
        4.5) bar='/////-----' ;;
        4.6) bar='/////-----' ;;
        4.7) bar='/////-----' ;;
        4.8) bar='/////-----' ;;
        4.9) bar='/////-----' ;;
        5) bar='/////-----' ;;
        5.1) bar='/////-----' ;;
        5.2) bar='/////-----' ;;
        5.3) bar='/////-----' ;;
        5.4) bar='/////-----' ;;
        5.5) bar='//////----' ;;
        5.6) bar='//////----' ;;
        5.7) bar='//////----' ;;
        5.8) bar='//////----' ;;
        5.9) bar='//////----' ;;
        6) bar='//////----' ;;
        6.1) bar='//////----' ;;
        6.2) bar='//////----' ;;
        6.3) bar='//////----' ;;
        6.4) bar='//////----' ;;
        6.5) bar='///////---' ;;
        6.6) bar='///////---' ;;
        6.7) bar='///////---' ;;
        6.8) bar='///////---' ;;
        6.9) bar='///////---' ;;
        7) bar='///////---' ;;
        7.1) bar='///////---' ;;
        7.2) bar='///////---' ;;
        7.3) bar='///////---' ;;
        7.4) bar='///////---' ;;
        7.5) bar='////////--' ;;
        7.6) bar='////////--' ;;
        7.7) bar='////////--' ;;
        7.8) bar='////////--' ;;
        7.9) bar='////////--' ;;
        8) bar='////////--' ;;
        8.1) bar='////////--' ;;
        8.2) bar='////////--' ;;
        8.3) bar='////////--' ;;
        8.4) bar='////////--' ;;
        8.5) bar='/////////-' ;;
        8.6) bar='/////////-' ;;
        8.7) bar='/////////-' ;;
        8.8) bar='/////////-' ;;
        8.9) bar='/////////-' ;;
        9) bar='/////////-' ;;
        9.1) bar='/////////-' ;;
        9.2) bar='/////////-' ;;
        9.3) bar='/////////-' ;;
        9.4) bar='/////////-' ;;
        9.5) bar='//////////' ;;
        9.6) bar='//////////' ;;
        9.7) bar='//////////' ;;
        9.8) bar='//////////' ;;
        9.9) bar='//////////' ;;
        10) bar='//////////' ;;
        *)  bar='----------' ;;
    esac

    echo "''$bar (''$bars)"
  '';
}
