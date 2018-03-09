{ system ? builtins.currentSystem }:
with (import <nixpkgs> { inherit system; });
let
  json = lib.importJSON ./nixpkgs.json;
  src = fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    inherit (json) rev sha256;
  };
in
  fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs";
    inherit (json) rev sha256;
  }
