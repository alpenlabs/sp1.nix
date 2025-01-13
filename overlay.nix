{ sp1-src }:
final: prev: {
  cargo-prove = prev.callPackage ./pkgs/cargo-prove.nix { inherit sp1-src; };
  sp1-rust-toolchain = prev.callPackage ./pkgs/sp1-rust-toolchain.nix { };
}
