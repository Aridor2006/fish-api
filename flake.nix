{
  description = "Fish helpers for API testing — env switching, basic + OAuth2 client_credentials (httpie + jq + pass)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in {
      packages = forAllSystems (pkgs: rec {
        default = api-test;

        api-test = pkgs.stdenvNoCC.mkDerivation {
          pname = "api-test";
          version = "0.1.0";
          src = ./.;

          dontBuild = true;

          installPhase = ''
            runHook preInstall
            mkdir -p $out/share/fish/vendor_functions.d
            mkdir -p $out/share/fish/vendor_completions.d
            mkdir -p $out/share/api-test/envs
            cp fish/functions/*.fish   $out/share/fish/vendor_functions.d/
            cp fish/completions/*.fish $out/share/fish/vendor_completions.d/
            cp envs/_template.fish     $out/share/api-test/envs/
            runHook postInstall
          '';

          meta = {
            description = "Fish functions + completions for API testing with env switching and basic/client_credentials auth";
            platforms = pkgs.lib.platforms.unix;
            # Runtime requirements (not bundled — install alongside): httpie, jq, pass
          };
        };
      });

      # Exposes the package under `pkgs.api-test` for downstream consumers.
      overlays.default = final: prev: {
        api-test = self.packages.${final.system}.api-test;
      };

      # Shell with the runtime deps the scripts call out to.
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [ fish httpie jq pass ];
        };
      });

      formatter = forAllSystems (pkgs: pkgs.nixpkgs-fmt);
    };
}
