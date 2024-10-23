{
  config,
  ...
}:
{
  azmo-workstations = {
    user = {
      enable = true;
      inherit (config.snowfallorg.user) name;
    };
    suites = {
      desktop.enable = true;
      desktop.hyprland.enable = true;
    };
    themes.catppuccin.enable = true;
    programs = {
      terminal = {
        editors = {
          neovim.enable = true;
        };
      };
    };
  };

  home.packages = [ ];
  programs = {
    bash = {
      enable = true;
    };
  };
  home.stateVersion = "24.11";
}
