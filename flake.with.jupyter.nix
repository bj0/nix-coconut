{
   description = "Flake to manage python workspace";

   inputs = {
     nixpkgs.url = "github:NixOS/nixpkgs/master";
     flake-utils.url = "github:numtide/flake-utils";
     mach-nix.url = "github:DavHau/mach-nix?ref=3.3.0";
     jupyterWith.url = "github:tweag/jupyterWith";
   };

   outputs = { self, nixpkgs, flake-utils, mach-nix, jupyterWith }:
     let
       python = "python38";
       pypiDataRev = "3948c3c729392348ee542a31a1bed92446e746be";
       pypiDataSha256 = "041rpjrwwa43hap167jy8blnxvpvbfil0ail4y4mar1q5f0q57xx";
     in flake-utils.lib.eachDefaultSystem (system:
       let
         pkgs = import nixpkgs {
             inherit system;
             overlays = nixpkgs.lib.attrValues jupyterWith.overlays;
             config = {
                 allowBroken = true;
                 allowUnfree = true;
                 allowUnsupportedSystem = true;
             };
         };
         mach-nix-wrapper = import mach-nix { inherit pkgs python pypiDataRev pypiDataSha256; };
         jupyter = import jupyterWith { inherit pkgs; };
        
        # make a python with updated coconut
        mnPython = mach-nix-wrapper.mkPython { 
            requirements = ''
                coconut>=1.5.0
                numpy
            '';
            ignoreCollisions = true;
        };

        # create kernel
        icoconut = pkgs.callPackage ./coconut {
            name = "coconut";
            python3 = mnPython.python;
        };

        # create jupyter environemnt
        jupyterEnvironment = jupyter.jupyterlabWith {
            kernels = [ icoconut ];
            # add console
            extraPackages = p: [ p.python3Packages.jupyter_console ];
        };

        in {

            # devShell = pkgs.mkShell {
            #     buildInputs = [                    
            #         jupyterEnvironment
            #         jupyterEnvironment.env.buildInputs
            #     ];

            #     shellHook = ''
            #         jupyter console --kernel coconut_coconut
            #     '';
            # };

            devShell = jupyterEnvironment.env.overrideAttrs (oldAttrs: {
                shellHook = oldAttrs.shellHook + ''
                    jupyter console --kernel coconut_coconut
                '';
            });
        }
     );

    #     mergeEnvs = envs:
    #     pkgs.mkShell (builtins.foldl' (a: v: {
    #         # runtime
    #         buildInputs = a.buildInputs ++ v.buildInputs;
    #         # build time
    #         nativeBuildInputs = a.nativeBuildInputs ++ v.nativeBuildInputs;
    #     }) (pkgs.mkShell { }) envs);
    #    in { devShell = mergeEnvs [ (devShell pkgs) pythonShell ]; });
 }