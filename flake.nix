{
   nixConfig.bash-prompt = "\\[\\033[01;32m\\]\\A| [nix] \\u@\\h\\[\\033[00m\\]:\\[\\033[01;34m\\]\\w\\[\\e[31m\\]\\[\\033[00m\\]$";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    src.url = "github:evhub/coconut/v3.1.0";
    src.flake = false;
  };

  outputs = inputs@{self, nixpkgs, flake-utils, src, ...}: 
    flake-utils.lib.eachDefaultSystem(system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in 
      rec {
        coconut = with pkgs.python3Packages; buildPythonPackage {
            pname = "coconut";
            version = "3.1.0";
            pyproject = true;
            
            src = src;

            nativeBuildInputs = [ setuptools psutil ];

            propagatedBuildInputs = [
              anyio
              async-generator
              cpyparsing
              mypy
              pygments
              prompt-toolkit
              setuptools
              watchdog
            ];

            nativeCheckInputs = [
              pexpect
              pytestCheckHook
              tkinter
            ];

            meta = with pkgs.lib; {
              description = "Simple, elegant, Pythonic functional programming";
              homepage = "http://coconut-lang.org/";
              changelog = "https://github.com/evhub/coconut/releases/tag/v${version}";
              license = licenses.asl20;
              maintainers = with maintainers; [ fabianhjr ];
            };

            pytestFlagsArray = [ "coconut/tests/constants_test.py" ];
          };

        packages = rec {
          python = (pkgs.python3.withPackages(ps: [
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
                ${python}/bin/coconut --jupyter console
            '';
          in pkgs.symlinkJoin {
              inherit name;
              paths = [ script ];
              buildInputs = [ pkgs.makeWrapper ];
              postBuild = "wrapProgram $out/bin/${name} --prefix PATH : $out/bin";
          };
        };
      });
}
