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
      development.enable = true;
    };
    themes.catppuccin.enable = true;
    programs = {
      terminal = {
        editors = {
          neovim.enable = true;
        };
        tools = {
          development = {
            git = {
              signingMethod = "gpg";
              signingKey = "0xDEE550054AA972F6";
            };
          };
          fzf.enable = true;
        };
      };
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
