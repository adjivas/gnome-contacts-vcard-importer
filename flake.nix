{
  description = "Imports version 2.1 vCards into the Gnome-Contacts contact database";

  inputs = {
    nixpkgs.url     = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }: flake-parts.lib.mkFlake { inherit inputs; } {
    systems = [ "x86_64-linux" "aarch64-linux" ];

    perSystem = { self', pkgs, lib, system, ... }: let
      py     = pkgs.python313;
      pyPkgs = pkgs.python313Packages;
      pyWith = py.withPackages (ps: [ ps.vobject ]);
    in {
      packages.default = pyPkgs.buildPythonApplication {
        pname = "gnomecontactsvcardimporter";
        version = "0.2.1";
        format = "other";
        src = ./.;

        propagatedBuildInputs = [ pyPkgs.vobject ];

        installPhase = ''
          install -Dm755 ${./gnomecontactsvcardimporter.py} \
            $out/bin/gnomecontactsvcardimporter
          patchShebangs $out/bin
        '';

        pythonImportsCheck = [ "vobject" ];
      };

      devShells.default = pkgs.mkShell {
        packages = [ pyWith ];
      };

      formatter = pkgs.nixpkgs-fmt;
    };
  };
}
