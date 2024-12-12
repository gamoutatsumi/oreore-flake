{
  # keep-sorted start
  installShellFiles,
  lib,
  makeRustPlatform,
  rust-bin,
  sources,
  # keep-sorted end
  ...
}:
let
  toolchain = rust-bin.stable.latest.default;
  rustPlatform = makeRustPlatform {
    cargo = toolchain;
    rustc = toolchain;
  };
in
rustPlatform.buildRustPackage rec {
  inherit (sources.tinty) version pname src;
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
