{ host, lib, ... }:
let
  domain = "hosts.gordonschulz.de";
in
{
  networking = {
    hostName = host;
    inherit domain;
    useDHCP = lib.mkDefault true;
  };
  systemd = {
    # even if networkd gets enabled, we are not using it on this system.
    # if this the systemd-networkd-wait-online unit gets enabled, it will fail - because it's not managing anything
    # therefore don't wait for the wait-online unit
    network.wait-online.enable = false;
  };
}
