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
  };

  home.packages = [ ];
  programs = {
    bash = {
      enable = true;
    };
  };
  home.stateVersion = "24.11";
}
