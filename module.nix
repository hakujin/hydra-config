{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.mercury-web-backend;
  baseDir = "/mercury";
in {
  ###### interface
  options = {
    services.mercury-web-backend = rec {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to run mercury-web-backend services.";
      };
      package = mkOption {
        type = types.path;
        description = "The mercury-web-backend package.";
      };

     gems = mkOption {
        type = types.path;
        description = "The mercury-web-backend-gems package.";
      };
    };
  };

  ###### implementation
  config = mkIf cfg.enable {
    users.extraGroups.mercury = {};
    users.extraUsers.mercury = {
      description = "mercury";
      group = "mercury";
      createHome = true;
      home = baseDir;
      useDefaultShell = true;
    };

    services.mercury-web-backend = {
      package = mkDefault pkgs.mercury.mercury-web-backend.build;
      gems = mkDefault pkgs.mercury.mercury-web-backend.gems;
    };

    systemd.services.mercury-web-backend-init = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "postgresql.service" ];
      serviceConfig = {
        ExecStart = ''
          ${cfg.gems}/bin/rake --rakefile ${cfg.package}/Rakefile --silent db:migrate
        '';
        User = "mercury";
        Group = "mercury";
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = cfg.package;
      };
    };

    systemd.services.mercury-web-backend = {
      wantedBy = [ "multi-user.target" ];
      bindsTo = [ "mercury-web-backend-init.service" ];
      after = [ "mercury-web-backend-init.service" ];
      # environment = env;
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/mercury-web-backend";
        User = "mercury";
        Group = "mercury";
        Restart = "always";
        WorkingDirectory = cfg.package;
      };
    };
  };
}
