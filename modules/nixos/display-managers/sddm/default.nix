{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) mkIf getExe' stringAfter;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.display-managers.sddm;
in
{
  options.${namespace}.display-managers.sddm = {
    enable = mkBoolOpt false "Whether or not to enable sddm.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.sddm-astronaut ];
    services = {
      displayManager = {
        sddm = {
          inherit (cfg) enable;
          # theme = "catppuccin-sddm-corners";
          # theme = "chili";
          package = pkgs.kdePackages.sddm;
          extraPackages = [ pkgs.sddm-astronaut ];
          theme = "sddm-astronaut-theme";
          wayland.enable = true;
        };
      };
      xserver = {
        xkb = {
          layout = "de";
        };
      };
    };

    system.activationScripts.postInstallSddm =
      stringAfter [ "users" ] # bash
        ''
          echo "Setting sddm permissions for user icon"
          ${getExe' pkgs.acl "setfacl"} -m u:sddm:x /home/${config.${namespace}.users.name}
          ${getExe' pkgs.acl "setfacl"} -m u:sddm:r /home/${config.${namespace}.users.name}/.face.icon || true
        '';
  };
}
