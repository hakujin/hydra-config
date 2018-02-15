let
  mkFetchGit = value: {
    inherit value;
    type = "git";
    emailresponsible = false;
  };
in rec {
  nixpkgs-src = builtins.importJSON ./nixpkgs.json;
  defaultSettings = {
    enabled = 1;
    hidden = false;
    keepnr = 5;
    schedulingshares = 42;
    checkinterval = 60;
    enableemail = false;
    emailoverride = "";
  };
  mkProject = project: branch: {
    nixexprpath = "release.nix";
    nixexprinput = "src";
    description = project;
    inputs = {
      src = mkFetchGit "ssh://git@github.com/hakujin/${project}.git ${branch}";
      nixpkgs = mkFetchGit "ssh://git@github.com/NixOS/nixpkgs.git ${nixpkgs-src.rev}";
    };
  };
  makePR = project: num: info: {
    name = "${project}-pr-${num}";
    value = defaultSettings // {
      nixexprinput = "src";
      nixexprpath = "release.nix";
      description = "PR ${num}: ${info.title}";
      inputs = {
        nixpkgs = mkFetchGit "ssh://git@github.com/NixOS/nixpkgs.git master";
        src = mkFetchGit "ssh://git@github.com/${info.base.repo.owner.login}/${info.base.repo.name}.git ${info.head.sha}";
      };
    };
  };
}
