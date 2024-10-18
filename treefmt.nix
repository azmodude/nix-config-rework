_: {
  projectRootFile = "flake.nix";
  programs = {
    just.enable = true;
    nixfmt.enable = true;
    statix.enable = true;
    yamlfmt.enable = true;
  };
  settings.formatter = {
    yamlfmt.excludes = [ "secrets/secrets.yaml" ];
  };
}
