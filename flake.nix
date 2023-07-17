{
   nixConfig.bash-prompt = "\\[\\033[01;32m\\]\\A| [nix] \\u@\\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\e[31m\\]\\[\\033[00m\\]$";

  inputs = {
    dream2nix.url = "github:nix-community/dream2nix";
    nixpkgs.follows = "dream2nix/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    src.url = "github:evhub/coconut";
    src.flake = false;
  };

  outputs = inputs@{self, dream2nix, flake-parts, src, ...}: flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux"];
      imports = [dream2nix.flakeModuleBeta];

      perSystem = {
        config,
        system,
        pkgs,
        ...
      }: {
        dream2nix.inputs."coconut" = {
          source = src;
          projects.coconut = {
              subsystem = "python";
              translator = "pip";
              subsystemInfo.pythonVersion = "3.10";
              subsystemInfo.extraSetupDeps = [
                "psutil"
              ];
            };
          };

        packages = rec {
          inherit (config.dream2nix.outputs.coconut.packages) coconut;
          
          python = (pkgs.python310.withPackages(ps: [
            ps.psutil
            ps.jupyter
            ps.numpy
            ps.pandas
            ps.matplotlib
            ps.networkx
            coconut
          ])).override (args: {ignoreCollisions = true; });

          coco = let
            name = "coco";
            script = pkgs.writeShellScriptBin name ''
                coconut --jupyter console
            '';
          in pkgs.symlinkJoin {
              inherit name;
              paths = [ script python ];
              buildInputs = [ pkgs.makeWrapper ];
              postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
          };

          defaultPackage = coco;
          defaultApp = coco;
        };
      };
    };
}