let
  bootstrapPkgs = import <nixpkgs> { };
  json = builtins.readFile ./.pinned-nixpkgs.json;
  nixpkgs = builtins.fromJSON json;
  src = bootstrapPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    inherit (nixpkgs) rev sha256;
  };
in src
