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

    # make a python with updated coconut
    mnPython = mach-nix.mkPython {
        requirements = ''
            coconut-develop>=1.5.0dev82
            numpy
        '';
        # requirements = ''
        #     coconut>=1.5.0
        # '';
        ignoreCollisions = true;
    };

    # need an overlay to get the right version of coconut in the jupyter (not-kernel) environment
    overlay = final: prev: {
                coco = mnPython.python.pkgs."coconut-develop";
            };

    jupyter = import (builtins.fetchGit {
        url = https://github.com/tweag/jupyterWith;
    }) {
        overlays = [overlay];
    };

    # create kernel
    icoconut = pkgs.callPackage ./coconut {
        name = "coconut";
        python3 = mnPython.python;
        pkg = "coconut-develop";
        packages = mnPython.python.pkgs.selectPkgs;
    };

    # create jupyter environemnt
    jupyterEnvironment = jupyter.jupyterlabWith {
        kernels = [ icoconut ];
        # add console and coconut to shell environment
        extraPackages = p: [ p.python3Packages.jupyter_console  p.coco ];
    };

in
    jupyterEnvironment.env
    .overrideAttrs (oldAttrs: {
        shellHook = oldAttrs.shellHook + ''
            jupyter console --kernel coconut_coconut
        '';
    })

    # mach-nix.mkPythonShell {
    #     requirements = ''
    #         coconut-develop[jupyter]>=1.5.0-post_dev82
    #     '';
    #     ignoreCollisions = true;
    #     # packagesExtra = [ coconut ];
    # }
#     machNix = mach-nix.mkPython rec {
#         packagesExtra = [ coconut ];
#     };

#     jupyter = import (builtins.fetchGit {
#         url = https://github.com/tweag/jupyterWith;
#         ref = "master";
#         #rev = "some_revision";
#     }) {};

#     iPython = jupyter.kernels.iPythonWith {
#         name = "mach-nix-jupyter";
#         python3 = machNix.python;
#         packages = machNix.python.pkgs.selectPkgs;
#     };

#     jupyterEnvironment = jupyter.jupyterlabWith {
#         kernels = [ iPython ];
#     };
# in
#     jupyterEnvironment.env



    # coconut = mach-nix.buildPythonPackage {
    #     pname = "coconut";
    #     version = "1.5.1";
    #     src = builtins.fetchGit {
    #         url = "https://github.com/evhub/coconut";
    #     };
    #     requirements = ''
    #         cpyparsing 
    #         pygments
    #         prompt-toolkit
    #         ipykernel 
    #         mypy 
    #         watchdog
    #     '';
    # };