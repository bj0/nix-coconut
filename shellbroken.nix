{ pkgs ? import (fetchTarball https://github.com/nixos/nixpkgs/archive/nixpkgs-unstable.tar.gz) {} }:

let
    mach-nix = import (builtins.fetchGit {
        url = "https://github.com/DavHau/mach-nix";
        ref = "refs/tags/3.3.0";
      }) {
        python = "python38";
        pypiDataRev = "e747f31df341f0b8fe9bef114043bdc51acbbcaf";
        pypiDataSha256 = "0knpr745w8xklklbb915z1084xymy0w1vi9hz9ss56hii70v4wrg";
    };

    jupyter = import (builtins.fetchGit {
        url = https://github.com/tweag/jupyterWith;
    }) {};

    # make a python with updated coconut
    mnPython = mach-nix.mkPython {
        requirements = ''
            coconut>=1.5.0
        '';
        ignoreCollisions = true;
    };

    # # create kernel
    icoconut = pkgs.callPackage ./coconut {
        name = "coconut";
        python3 = mnPython.python;
        packages = mnPython.python.pkgs.selectPkgs;
    };

    # create jupyter environemnt
    jupyterEnvironment = jupyter.jupyterlabWith {
        kernels = [ icoconut ];
        # add console
        extraPackages = p: [ p.python3Packages.jupyter_console ];
    };

in
    jupyterEnvironment.env
    # jupyterEnvironment.env.overrideAttrs (oldAttrs: {
    #     shellHook = oldAttrs.shellHook + ''
    #         jupyter console --kernel coconut_coconut
    #     '';
    # })