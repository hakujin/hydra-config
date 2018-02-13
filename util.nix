let
  mkFetchGithub = value: {
    inherit value;
    type = "git";
    emailresponsible = false;
  };
in rec {
  nixpkgs-src = builtins.fromJSON (builtins.readFile ./nixpkgs.json);
  defaultSettings = {
    enabled = 1;
    hidden = false;
    nixexprinput = "jobsets";
    keepnr = 5;
    schedulingshares = 42;
    checkinterval = 60;
    enableemail = false;
    emailoverride = "";
  };
  mkProject = project: branch: nixpkgsRev: {
    nixexprpath = "release.nix";
    nixexprinput = "src";
    description = project;
    inputs = {
      src = mkFetchGithub "https://github.com/hakujin/${project}.git ${branch}";
      nixpkgs = mkFetchGithub "https://github.com/NixOS/nixpkgs.git ${nixpkgs-src.rev}";
    };
  };
  makePR = project: num: info: {
    name = "${project}-pr-${num}";
    value = defaultSettings // {
      description = "PR ${num}: ${info.title}";
      nixexprinput = "src";
      nixexprpath = "release.nix";
      inputs = {
        nixpkgs = mkFetchGithub "https://github.com/NixOS/nixpkgs.git master";
        src = mkFetchGithub "https://github.com/${info.base.repo.owner.login}/${info.base.repo.name}.git ${info.head.sha}";
      };
    };
  };
}
