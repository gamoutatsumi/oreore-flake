{
  projectRootFile = "flake.nix";
  programs = {
    # keep-sorted start block=yes
    keep-sorted = {
      enable = true;
    };
    nixfmt = {
      enable = true;
    };
    shfmt = {
      enable = true;
    };
    # keep-sorted end
  };
}
