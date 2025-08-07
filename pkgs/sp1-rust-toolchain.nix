{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  xz,
  zlib,
  ncurses,
  gcc-unwrapped,
}:

stdenv.mkDerivation rec {
  pname = "sp1-rust-toolchain";
  version = "1.81.0";

  src = fetchurl (
    if stdenv.isDarwin then
      if stdenv.isAarch64 then
        {
          url = "https://github.com/succinctlabs/rust/releases/download/v${version}/rust-toolchain-aarch64-apple-darwin.tar.gz";
          hash = "sha256-tVvf3syK18uRLp3Idam3oqjcZvB13JBoXBkskbkQQZQ=";
        }
      else
        {
          url = "https://github.com/succinctlabs/rust/releases/download/v${version}/rust-toolchain-x86_64-apple-darwin.tar.gz";
          hash = "sha256-5DTmfkU1hr7VG/T4BhYaAaURti2PfXM/W38x7dOD+UM=";
        }
    else if stdenv.isAarch64 then
      {
        url = "https://github.com/succinctlabs/rust/releases/download/v${version}/rust-toolchain-aarch64-unknown-linux-gnu.tar.gz";
        hash = "sha256-aLxKKSN+Lrhi2jYyTRnPg1u5P0UQatIGuheDb7eGLzI=";
      }
    else
      {
        url = "https://github.com/succinctlabs/rust/releases/download/v${version}/rust-toolchain-x86_64-unknown-linux-gnu.tar.gz";
        hash = "sha256-+Ll4tE/e39nz3+oSfuEfE+4v2q/96iYZSJ3/e755HM4=";
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

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/lib
    cp -r bin/* $out/bin/
    cp -r lib/* $out/lib/

    runHook postInstall
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
