let
  overlays = import ./overlays.nix;
  config = { allowBroken = true; };
  src = import ./pinned-nixpkgs.nix;
  pkgs = import src {
    inherit config;
    inherit overlays;
  };
in pkgs
