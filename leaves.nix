{ prsJSON, nixpkgs }:
let
  util = import ./util.nix;
  pkgs = import nixpkgs {};
  prs = builtins.fromJSON (builtins.readFile prsJSON);
  prJobsets = pkgs.lib.listToAttrs (pkgs.lib.mapAttrsToList (util.makePR "leaves") prs);
  mainJobsets = with pkgs.lib; mapAttrs (name: settings: util.defaultSettings // settings) (rec {
    leaves = util.mkProject "leaves" "master" util.nixpkgs-src.rev;
  });
  jobsetsAttrs = prJobsets // mainJobsets;
  jobsetJson = pkgs.writeText "spec.json" (builtins.toJSON jobsetsAttrs);
in {
  jobsets = with pkgs.lib; pkgs.runCommand "spec.json" {} ''
    cp ${jobsetJson} $out
  '';
}
