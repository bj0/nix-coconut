{
   description = "Flake to manage python workspace";

   nixConfig.bash-prompt = "\\[\\033[01;32m\\]\\A| [nix] \\u@\\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\e[31m\\]\\[\\033[00m\\]$";

   inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    mach-nix = {
        url = "github:DavHau/mach-nix";
        inputs.nixpkgs.follows = "nixpkgs";
        inputs.flake-utils.follows = "flake-utils";
        inputs.pypi-deps-db.url = "github:DavHau/pypi-deps-db/694d987fe6acf9bb272f000b4d4512a97d92f363";
    };
   };

   outputs = { self, nixpkgs, mach-nix, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
        let
            pkgs = import nixpkgs { inherit system; };
            
        in rec {
            packages = {
                python = mach-nix.lib.${system}.mkPython {
                    requirements = ''
                        coconut>=1.6.0
                        numpy
                        pandas
                        matplotlib
                        networkx
                        jupyter_client=6.1.12 # until jupyter-console releases a fix for client 7.x, we have to downgrade
                        jupyter-console
                    '';
                    ignoreCollisions = true;
                    ignoreDataOutdated = true;
                };            

            coconut = 
            let
                name = "coconut";
                script = pkgs.writeShellScriptBin name ''
                    jupyter console --kernel coconut
                '';
                in pkgs.symlinkJoin {
                    inherit name;
                    paths = [ script packages.python ];
                    buildInputs = [ pkgs.makeWrapper ];
                    postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
                };

            };
            devShell = (import ./shell.nix { 
                inherit pkgs; 
                mach-nix=mach-nix.lib.${system};
                });
            defaultPackage = packages.coconut;
        }
    );
}

        