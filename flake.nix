{
   description = "Flake to manage python workspace";

   nixConfig.bash-prompt = "\\[\\033[01;32m\\]\\A| [nix] \\u@\\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\e[31m\\]\\[\\033[00m\\]$";

   inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    mach-nix = {
        url = "github:DavHau/mach-nix";
        inputs.nixpkgs.follows = "nixpkgs";
        inputs.flake-utils.follows = "flake-utils";
        inputs.pypi-deps-db = {
            url = "github:DavHau/pypi-deps-db";
            flake = false;
        };
    };
   };

   outputs = { self, nixpkgs, mach-nix, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
        let
            pkgs = import nixpkgs { inherit system; };
        in {
            devShell = (import ./shell.nix { 
                inherit pkgs; 
                mach-nix=mach-nix.lib.${system};
                });
        }
    );
}

        