{
  description = "lugatuic.github.io";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      with import nixpkgs {
        inherit system;
      };
      let
        fs = lib.fileset;
        lugatuic = stdenv.mkDerivation {
          name = "lugatuic";
          src = fs.toSource {
            root = ./.;
            fileset = fs.unions [
              (fs.fileFilter (file: file.hasExt "html" || file.hasExt "yml") ./.)
              ./Makefile
              ./content
              ./scripts
            ];
          };
          nativeBuildInputs = [
            curl
            libxslt
            pandoc
            rsync
            static-web-server
          ];
          installPhase = ''
            rsync -avzh public/ $out/
          '';
        };
      in
      {
        packages.default = dockerTools.buildNixShellImage {
          drv = lugatuic;
          run = "buildDerivation && static-web-server -d $out -p 8787";
        };

        devShell = mkShell {
          inputsFrom = [ lugatuic ];
        };
      }
    );
}

# vim: ts=2:sw=2:expandtab:
