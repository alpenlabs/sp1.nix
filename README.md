# SP1 Nix Package Collection

This repository provides Nix packages for SP1 (Succinct Labs) tools,
including [`cargo-prove`](https://github.com/succinctlabs/sp1/tree/dev/crates/cli)
and the [`succinctlabs/rust` toolchain](https://github.com/succinctlabs/rust).

## Packages

- **`cargo-prove`** - The SP1 CLI tool for generating and verifying zero-knowledge proofs
- **`sp1-rust-toolchain`** - Succinct Labs' custom Rust toolchain optimized for SP1

Both packages are available for the following platforms:

- `x86_64-linux`
- `aarch64-linux`
- `x86_64-darwin`
- `aarch64-darwin`

## Usage

### With Flakes

Add this repository as an input to your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sp1-nix = {
      url = "github:alpenlabs/sp1.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, sp1-nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ sp1-nix.overlays.default ];
        };
      in {
        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            cargo-prove
            sp1-rust-toolchain
          ];
        };

        # Direct package access
        packages = {
          inherit (pkgs) cargo-prove sp1-rust-toolchain;
        };
      });
}
```

#### Quick Development Shell

For a quick development environment, you can use:

```bash
nix develop github:alpenlabs/sp1.nix
```

Or create a temporary shell with the tools:

```bash
nix shell github:alpenlabs/sp1.nix#cargo-prove
nix shell github:alpenlabs/sp1.nix#sp1-rust-toolchain
```

### Without Flakes (shell.nix)

Create a `shell.nix` file in your project:

```nix
let
  # Pin nixpkgs to a specific version for reproducibility
  pkgs = import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz";
  }) {
    overlays = [
      # Import the SP1 overlay
      (import (fetchTarball {
        url = "https://github.com/alpenlabs/sp1.nix/archive/main.tar.gz";
      })).overlays.default
    ];
  };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    cargo-prove
    sp1-rust-toolchain
  ];

  shellHook = ''
    echo "SP1 development environment loaded!"
    echo "Available tools:"
    echo "  - cargo-prove: $(cargo-prove --version 2>/dev/null || echo 'not found')"
  '';
}
```

Then enter the shell with:

```bash
nix-shell
```

### Using Specific Versions

To use a specific version of this overlay, you can pin it to a commit:

#### With Flakes

```nix
{
  inputs = {
    sp1-nix = {
      url = "github:alpenlabs/sp1.nix/COMMIT_HASH";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

#### Without Flakes

```nix
let
  sp1-nix = fetchTarball {
    url = "https://github.com/alpenlabs/sp1.nix/archive/COMMIT_HASH.tar.gz";
    sha256 = "0000000000000000000000000000000000000000000000000000"; # Use real hash
  };
  pkgs = import <nixpkgs> {
    overlays = [ (import sp1-nix).overlays.default ];
  };
in
# ... rest of your configuration
```

## Building Locally

To build the packages locally:

```bash
# Clone this repository
git clone https://github.com/alpenlabs/sp1.nix.git
cd sp1.nix

# Build individual packages
nix build .#cargo-prove
nix build .#sp1-rust-toolchain

# Enter development shell
nix develop
```

## Contributing

1. Fork the repository
2. Make your changes
3. Test builds on your platform: `nix build .#cargo-prove .#sp1-rust-toolchain`
4. Submit a pull request

The CI will test builds on both Linux and macOS for all packages.

## License

This repository is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
