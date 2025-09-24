{
  description = "Flake to build devshell for ComfyUI";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          overlays = [];
        };
      in {
        devShells.default = throw "You need to specify which output you want: CPU, ROCm, CUDA.";
        devShells.cpu = import ./impl.nix {
          inherit pkgs;
          variant = "CPU";
        };

        devShells.cuda = import ./impl.nix {
          inherit pkgs;
          variant = "CUDA";
        };

        devShells.rocm = import ./impl.nix {
          inherit pkgs;
          variant = "ROCm";
        };
      }
    );
}
