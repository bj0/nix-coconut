{ pkgs ? import (fetchTarball https://github.com/nixos/nixpkgs/archive/nixpkgs-unstable.tar.gz) {} }:

let
    jupyter = import (builtins.fetchGit {
        url = https://github.com/tweag/jupyterWith;
    }) {};

    iPython = jupyter.kernels.iPythonWith {
        name = "ipy";
        packages = p: with p; [ numpy coconut trio ];
    };

    jupyterEnvironment = jupyter.jupyterlabWith {
        kernels = [ iPython ];
        extraPackages = p: [ p.python3Packages.jupyter_console ];
    };

in
    jupyterEnvironment.env
