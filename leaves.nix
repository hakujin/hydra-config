{ nixpkgs, prsJSON }:
let
  util = import ./util.nix;
  pkgs = import nixpkgs {};
  prs = builtins.importJSON prsJSON;
  prJobsets = pkgs.lib.listToAttrs (pkgs.lib.mapAttrsToList (util.makePR "leaves") prs);
  mainJobsets = pkgs.lib.mapAttrs (name: settings: util.defaultSettings // settings) (rec {
    leaves = util.mkProject "leaves" "master";
  });
in {
  jobsets = pkgs.writeText "spec.json" (builtins.toJSON (prJobsets // mainJobsets));
}
