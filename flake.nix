{
  description = "Apply ICC VCGT calibration curves on wlroots Wayland compositors";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          wlr-vcgt-loader = pkgs.stdenv.mkDerivation {
            pname = "wlr-vcgt-loader";
            version = "0.1.0";

            src = nixpkgs.lib.fileset.toSource {
              root = ./.;
              fileset = nixpkgs.lib.fileset.unions [
                ./main.c
                ./Makefile
                ./protocol
              ];
            };

            nativeBuildInputs = with pkgs; [
              pkg-config
              wayland-scanner
            ];

            buildInputs = with pkgs; [
              wayland
              lcms2
            ];

            makeFlags = [ "PREFIX=${placeholder "out"}" ];

            meta = with pkgs.lib; {
              description = "Apply ICC VCGT calibration curves on wlroots Wayland compositors";
              license = licenses.mit;
              platforms = platforms.linux;
              mainProgram = "wlr-vcgt-loader";
            };
          };

          default = self.packages.${system}.wlr-vcgt-loader;
        });

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            inputsFrom = [ self.packages.${system}.wlr-vcgt-loader ];
          };
        });

      overlays.default = final: prev: {
        wlr-vcgt-loader = self.packages.${prev.stdenv.hostPlatform.system}.wlr-vcgt-loader;
      };

      homeManagerModules.default = import ./nix/hm-module.nix self;
    };
}
