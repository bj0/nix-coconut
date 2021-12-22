{ 
    mach-nix ? import (builtins.fetchGit {
        url = "https://github.com/DavHau/mach-nix";
        rev = "31b21203a1350bff7c541e9dfdd4e07f76d874be";
      }) {
        # python = "python38";
        pypiDataRev = "3948c3c729392348ee542a31a1bed92446e746be";
        pypiDataSha256 = "041rpjrwwa43hap167jy8blnxvpvbfil0ail4y4mar1q5f0q57xx";
    },
    # make a python with updated coconut
    python ? mach-nix.mkPython {
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
    },

    pkgs ? import (fetchTarball https://github.com/nixos/nixpkgs/archive/nixpkgs-unstable.tar.gz) {} 
}:

pkgs.mkShell {
    buildInputs = [ python ];

    shellHook = ''
        jupyter console --kernel coconut
    '';
}
