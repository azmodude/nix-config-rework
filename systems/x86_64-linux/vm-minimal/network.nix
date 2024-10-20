{ host, ... }:
let
  domain = "hosts.gordonschulz.de";
in
{
  networking = {
    hostName = host;
    inherit domain;
    # useDHCP = false;
    # networkmanager.enable = true;
  };
}
