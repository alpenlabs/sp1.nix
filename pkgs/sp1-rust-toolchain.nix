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

  src = fetchurl {
    url = "https://github.com/succinctlabs/rust/releases/download/v${version}/rust-toolchain-x86_64-unknown-linux-gnu.tar.gz";
    sha256 = "sha256-+Ll4tE/e39nz3+oSfuEfE+4v2q/96iYZSJ3/e755HM4=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
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
    platforms = [ "x86_64-linux" ];
  };
}
