{
  nixConfig.bash-prompt = "\\[\\033[01;32m\\]\\A| [nix] \\u@\\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\e[31m\\]\\[\\033[00m\\]$";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    #src.url = "github:evhub/coconut/v3.1.0";
    #src.flake = false;
  };

  outputs = {
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages = rec {
        python =
          (pkgs.python3.withPackages (ps: [
            ps.psutil
            ps.jupyter
            ps.numpy
            ps.pandas
            ps.matplotlib
            ps.networkx
            ps.coconut
          ]))
          .override (args: {ignoreCollisions = true;});

        coco = let
          name = "coco";
          script = pkgs.writeShellScriptBin name ''
            ${python}/bin/coconut --jupyter console
          '';
        in
          script;
        # pkgs.symlinkJoin {
        #   inherit name;
        #   paths = [script];
        #   buildInputs = [pkgs.makeWrapper];
        #   postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
        # };
      };
    });
}
