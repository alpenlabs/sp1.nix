{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  xz,
  zlib,
  ncurses,
  gcc-unwrapped,
  cargo,
}:

stdenv.mkDerivation rec {
  pname = "sp1-rust-toolchain";
  version = "1.88.0";

  src = fetchurl (
    if stdenv.isDarwin then
      if stdenv.isAarch64 then
        {
          url = "https://github.com/succinctlabs/rust/releases/download/succinct-${version}/rust-toolchain-aarch64-apple-darwin.tar.gz";
          hash = "sha256-CUnW2kCfNbLr9FVPZ1FOBPSlFeKNwZ8DjgfX5pQpEHM=";
        }
      else
        {
          url = "https://github.com/succinctlabs/rust/releases/download/succinct-${version}/rust-toolchain-x86_64-apple-darwin.tar.gz";
          hash = "sha256-JG8VZ0ApQ1Kveo9xOrtLoWXQjsZzVxOmt61Mqv9o2oI=";
        }
    else if stdenv.isAarch64 then
      {
        url = "https://github.com/succinctlabs/rust/releases/download/succinct-${version}/rust-toolchain-aarch64-unknown-linux-gnu.tar.gz";
        hash = "sha256-Np5xUvWcNOH9Sbx9udgkzkA1fRKHSdmU5hV/6FWH5ao=";
      }
    else
      {
        url = "https://github.com/succinctlabs/rust/releases/download/succinct-${version}/rust-toolchain-x86_64-unknown-linux-gnu.tar.gz";
        hash = "sha256-pbO+AiR/FmZsbZt7ormGEfbsssztatRDpzrzB6wh5XA=";
      }
  );

  nativeBuildInputs = lib.optionals stdenv.isLinux [
    autoPatchelfHook
  ];

  buildInputs = lib.optionals stdenv.isLinux [
    xz
    zlib
    ncurses
    gcc-unwrapped
    stdenv.cc.cc.lib
  ];

  sourceRoot = ".";

  # Prevent stripping of .rlib files which removes .rmeta sections needed for compilation
  dontStrip = true;

  # Also prevent ELF patching which might corrupt the metadata
  dontPatchELF = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib
    cp -r bin/* $out/bin/
    cp -r lib/* $out/lib/

    runHook postInstall
  '';

  postInstall = ''
    # Make the toolchain available as +succinct
    mkdir -p $out/toolchains/succinct
    ln -sf $out/* $out/toolchains/succinct/

    # Create a wrapper script for cargo +succinct
    mkdir -p $out/bin
    cat > $out/bin/cargo-succinct << 'EOF'
    #!/bin/bash
    RUSTC_PATH="$0"
    RUSTC_PATH="''${RUSTC_PATH%/bin/cargo-succinct}/bin/rustc"
    export RUSTC="$RUSTC_PATH"
    exec ${cargo}/bin/cargo "$@"
    EOF
    chmod +x $out/bin/cargo-succinct
  '';

  meta = with lib; {
    description = "Succinct Labs Rust toolchain";
    homepage = "https://github.com/succinctlabs/rust";
    license = licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
  };
}
