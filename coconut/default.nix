{ stdenv
, python3
, name ? "nixpkgs"
, packages ? p: []
, pkgs
, pkg ? "coconut"
}:

let
  kernelEnv = python3.withPackages ( p: 
    packages p ++ (with p; [ "${pkg}" ])
    );

  kernelFile = {
    argv = [
      "${kernelEnv.interpreter}"
      "-m"
      "coconut.icoconut"
      "-f"
      "{connection_file}"
    ];
    display_name = "Coconut " + name;
    language = "coconut";
    logo64 = "logo-64x64.svg";
  };

  icoconut = stdenv.mkDerivation {
    name = "icoconut-kernel";
    phases = "installPhase";
    src = ./coconut.png;
    buildInputs = [];
    installPhase = ''
      mkdir -p $out/kernels/coconut_${name}
      cp $src $out/kernels/coconut_${name}/logo-64x64.png
      echo '${builtins.toJSON kernelFile}' > $out/kernels/coconut_${name}/kernel.json
    '';
  };
in
  {
    spec = icoconut;
    runtimePackages = packages pkgs;
  }