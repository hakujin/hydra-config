{ nixpkgs, prsJSON }:
with (import <nixpkgs> {});
let
  util = import ./util.nix { inherit nixpkgs; };
  prs = lib.importJSON prsJSON;
  prJobsets = lib.listToAttrs (lib.mapAttrsToList (util.makePR "leaves") prs);
  mainJobsets = lib.mapAttrs (name: settings: util.defaultSettings // settings) (rec {
    leaves = util.mkProject "leaves" "master";
  });
in {
  jobsets = writeText "spec.json" (builtins.toJSON (prJobsets // mainJobsets));
}
