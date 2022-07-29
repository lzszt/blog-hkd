let
  customHaskellPackages = self: super: {
    haskellPackages = super.haskellPackages.override {
      overrides = hself: hsuper:
        let
          dontCheck = super.haskell.lib.dontCheck;
          dontHaddock = super.haskell.lib.dontHaddock;

          hkd-src = self.nix-gitignore.gitignoreSource [
            "*.git"
            "dist"
            "dist-newstyle"
          ] ../.;
          hkd = hself.callCabal2nix "hkd"
            hkd-src { };
        in {
          # We add ourselves to the set of haskellPackages.
          inherit hkd;
        };
    };
  };
in [ customHaskellPackages ]
