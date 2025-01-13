{
  lib,
  rustPlatform,
  sp1-src,
}:
rustPlatform.buildRustPackage rec {
  pname = "cargo-prove";
  version = (builtins.fromTOML (builtins.readFile "${src}/Cargo.toml")).workspace.package.version;
  src = sp1-src;
  buildAndTestSubdir = "crates/cli";
  doCheck = false;
  cargoLock = {
    lockFile = "${src}/Cargo.lock";
    outputHashes = {
      "p3-air-0.1.0" = "sha256-OgLF1AUNoSzqHppAAwYxwZV9hBeXzwH5uIjsLCsFkk0=";
    };
  };
}
