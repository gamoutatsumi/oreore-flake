{
  pkgs,
  makeRustPlatform,
  rust-bin,
  lib,
  installShellFiles,
}:
let
  toolchain = rust-bin.stable.latest.default;
  rustPlatform = makeRustPlatform {
    cargo = toolchain;
    rustc = toolchain;
  };
  version = "0.23.0";
  pname = "tinty";
  src = pkgs.fetchFromGitHub {
    owner = "tinted-theming";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-5KrXvE+RLkypqKg01Os09XGxrqv0fCMkeSD//E5WrZc=";
  };
in
rustPlatform.buildRustPackage {
  inherit version pname src;
  cargoLock = {
    lockFile = "${src}/Cargo.lock";
  };
  checkPhase = ''
    true
  '';
  postInstall = ''
    export XDG_DATA_HOME=$(mktemp -d)
    export XDG_CONFIG_HOME=$(mktemp -d)
    installShellCompletion --cmd ${pname} \
    --fish <($out/bin/${pname} generate-completion fish) \
    --bash <($out/bin/${pname} generate-completion bash) \
    --zsh <($out/bin/${pname} generate-completion zsh)
  '';
  nativeBuildInputs = [ installShellFiles ];
  meta = {
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mainProgram = "${pname}";
  };
}
