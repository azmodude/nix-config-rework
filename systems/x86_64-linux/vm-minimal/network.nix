{ host, ... }:
{
  networking = {
    hostName = host;
    # useDHCP = false;
    # networkmanager.enable = true;
  };
}
