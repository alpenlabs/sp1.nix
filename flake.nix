{
  description = "SP1 Nix Package Collection";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sp1-src = {
      url = "github:succinctlabs/sp1";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      rust-overlay,
      sp1-src,
    }:
    {
      overlays = {
        my-overlay = import ./overlay.nix { inherit sp1-src; };
        default = self.overlays.my-overlay;
      };
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            rust-overlay.overlays.default
            self.overlays.default
          ];
        };
      in
      {
        packages = {
          cargo-prove = pkgs.cargo-prove;
          sp1-rust-toolchain = pkgs.sp1-rust-toolchain;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            cargo-prove
            sp1-rust-toolchain
          ];
        };

        formatter = pkgs.nixfmt-rfc-style;
      }
    );
}
