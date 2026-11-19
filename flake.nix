
{
  description = "Breve flake de ambiente haskell.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      hls = pkgs.haskell-language-server.override {
        supportedGhcVersions = [ "910" ];
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          ghc
          cabal-install
          hls
          hlint
          hpack
        ];
      };
    };
}
