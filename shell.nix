let pkgs = import ./nix/pkgs.nix;
in pkgs.haskellPackages.shellFor {
  packages = p: [ p.hkd ];
  buildInputs = [
    pkgs.haskellPackages.cabal-install
    pkgs.haskellPackages.ghc
    pkgs.haskellPackages.hlint
    pkgs.haskellPackages.fourmolu
    pkgs.haskellPackages.ghcid
    pkgs.haskellPackages.haskell-language-server
  ];
}
