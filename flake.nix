{
  description = "Breve flake de ambiente haskell.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      haskellPackages = pkgs.haskell.packages.ghc910;

      hls = pkgs.haskell-language-server.override {
        supportedGhcVersions = [ "910" ];
      };
      hpack = haskellPackages.hpack_0_39_1;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.ghc
          pkgs.cabal-install
          hls
          pkgs.hlint
          hpack
        ];
      };
    };
}
