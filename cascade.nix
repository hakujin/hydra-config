{ build, gems, ... }:
let
  system = "x86_64-linux";
  pinned = import ./pinned-nixpkgs.nix { inherit system; };
  pkgs = import pinned { inherit system; };
  nixos-ec2 = import (pkgs.path + "/nixos") {
    inherit system;
    configuration = {
      imports = [
        (pkgs.path + "/nixos/modules/virtualisation/amazon-image.nix")
        ./module.nix
      ];
      ec2.hvm = true;

      nix = {
        autoOptimiseStore = true;
        gc.automatic = true;
      };
      nixpkgs.config.packageOverrides = pkgs: {
        mercury =  { inherit build gems; };
      };

      services = {
        mercury-web-backend = {
          enable = true;
        };
        postgresql = {
          enable = true;
          authentication = pkgs.lib.mkForce ''
            local all all              trust
            host  all all 127.0.0.1/32 trust
            host  all all ::1/128      trust
          '';
        };
      };

      networking.firewall.allowedTCPPorts = [ 3000 ];
    };
  };
in {
  image = nixos-ec2.system;
}
