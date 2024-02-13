{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.boot.loader.stand;
  builder = import ./stand-conf-builder.nix { inherit pkgs; };
  timeoutStr = if config.boot.loader.timeout == null then "-1" else toString config.boot.loader.timeout;
in {
  options = {
    boot.loader.stand = {
      enable = mkEnableOption (mdDoc ''
        Use the FreeBSD boot loader.
      '');
      
      configurationLimit = mkOption {
        default = 20;
        example = 10;
        type = types.int;
        description = lib.mdDoc ''
          Maximum number of configurations in the boot menu.
        '';
      };

      populateCmd = mkOption {
        type = types.str;
        readOnly = true;
        description = lib.mdDoc ''
          Contains the builder command used to populate an image,
          honoring all options except the `-c <path-to-default-configuration>`
          argument.
          Useful to have for sdImage.populateRootCommands
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    system.build.installBootLoader = "TARGET=/boot GENERATIONS=${cfg.configurationLimit} TIMEOUT=${timeoutStr} ${builder}";
    system.boot.loader.id = "stand";
    boot.loader.stand.populateCmd = "${populateBuilder} ${builderArgs}";
  };
}
