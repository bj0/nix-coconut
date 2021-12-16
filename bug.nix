{ pkgs ? import (fetchTarball https://github.com/nixos/nixpkgs/archive/nixpkgs-unstable.tar.gz) {} }:

let
    jupyter = import (builtins.fetchGit {
        url = https://github.com/tweag/jupyterWith;
    }) {};

    # create jupyter environemnt
    jupyterEnvironment = jupyter.jupyterlabWith {
        # add console
        # extraPackages = p: [ p.python3Packages.jupyter_console ];
    };

in
    jupyterEnvironment.env
