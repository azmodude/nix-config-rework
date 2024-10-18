{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
{
  # use nvd to report changes after activation
  system.activationScripts.diff = {
    supportsDryActivation = true;
    text = ''
      echo
      ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
      echo
    '';
  };
  sops = {
    age = {
      sshKeyPaths = [ (builtins.elemAt config.services.openssh.hostKeys 0).path ];
    };
    defaultSopsFile = lib.snowfall.fs.get-file "secrets/secrets.yaml";
    # sops-nix options: https://dl.thalheim.io/
    secrets = {
      test-key = { };
    };
  };
}
