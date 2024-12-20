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
    security = {
      gpg = {
        enable = true;
        fetchKey = {
          enable = true;
          Url = "https://github.com/azmodude.gpg";
          Sha256 = "sha256:1s9y4k90hjl7k75is6lyp491hg1my3vm1kxxahyslj5wy7w09pi8";
        };
      };
    };
  };

  home.packages = [ ];

  programs = {
    bash = {
      enable = true;
    };
    zsh = {
      enable = true;
    };
  };
  home.stateVersion = "24.11";
}
