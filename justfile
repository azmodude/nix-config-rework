export NIX_CONFIG := "extra-experimental-features = nix-command flakes repl-flake"
GIT_TLD := shell('git rev-parse --show-toplevel')
user := env_var('USER')
host := `hostname`

default:
    just --list

na-install target encryptionkeys host:
    nix run github:nix-community/nixos-anywhere -- --flake .#{{ target }} --disk-encryption-keys /tmp/pass-zpool-rpool {{ encryptionkeys }} --extra-files {{ GIT_TLD }}/systems/x86_64-linux/{{ target }}/extra-files root@{{ host }}

na-install-local target encryptionkeys host $SSHPASS:
    nix run github:nix-community/nixos-anywhere -- --flake .#{{ target }} --disk-encryption-keys /tmp/pass-zpool-rpool {{ encryptionkeys }} --extra-files {{ GIT_TLD }}/systems/x86_64-linux/{{ target }}/extra-files --env-password root@127.0.0.1

na-vm-test target:
    nix run github:nix-community/nixos-anywhere -- --flake .#{{ target }} --vm-test

na-install-btrfs-arm target host:
    nix run github:nix-community/nixos-anywhere -- --build-on-remote --flake .#{{ target }} root@{{ host }}

na-install-btrfs target host:
    nix run github:nix-community/nixos-anywhere --  --flake .#{{ target }} root@{{ host }}

# install home-manager for user=<user@host>
hm-install:
    nix build --no-link .#homeConfigurations.{{user}}@{{host}}.activationPackage
    "$(nix path-info .#homeConfigurations.{{user}}@{{host}}.activationPackage)"/activate
# switch home-manager for user=<user@host>
hm-switch:
    home-manager switch --flake .?submodules=1#{{user}}@{{host}}
# update flakes
update-flake-only:
    nix flake update
# update for host=<host>
switch:
    sudo nixos-rebuild switch --flake .#{{host}}
boot:
    sudo nixos-rebuild boot --flake .#{{host}}
# update flakes and rebuild-switch for host=<host>
update: update-flake-only && switch hm-switch

