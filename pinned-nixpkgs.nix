{ system ? builtins.currentSystem, config ? {} }:
with (import <nixpkgs> { inherit system config; });
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
