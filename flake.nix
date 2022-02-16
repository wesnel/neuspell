{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "nixpkgs/nixos-21.11"; 
    poetry2nix.url = "github:nix-community/poetry2nix";
  };

  outputs = inputs @ { self, nixpkgs, flake-utils, poetry2nix, ... }:
    let
      packageName = "neuspell";
    in {
      overlay = nixpkgs.lib.composeManyExtensions [
        poetry2nix.overlay (final: prev: {
          ${packageName} = prev.poetry2nix.mkPoetryApplication {
            projectDir = ./.;
          };
        })
      ];
    } // (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;

          overlays = [ self.overlay ];
        };
      in {
        packages.${packageName} = pkgs.${packageName};

        defaultPackage = self.packages.${system}.${packageName};

        devShell = pkgs.mkShell { 
          buildInputs = with pkgs; [
            poetry

            (python3.withPackages(p: with p; [
              python-lsp-server
            ]))
          ];
        };
      }
    ));
}
