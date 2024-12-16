export NIX_CONFIG := "extra-experimental-features = nix-command flakes repl-flake"

default:
    just --list

na-install target encryptionkeys host:
    nix run github:nix-community/nixos-anywhere -- --flake .#{{ target }} --disk-encryption-keys /tmp/pass-zpool-rpool {{ encryptionkeys }} --extra-files ./systems/x86_64-linux/{{ target }}/extra-files root@{{ host }}

na-install-local target encryptionkeys host $SSHPASS:
    nix run github:nix-community/nixos-anywhere -- --flake .#{{ target }} --disk-encryption-keys /tmp/pass-zpool-rpool {{ encryptionkeys }} --extra-files ./systems/x86_64-linux/{{ target }}/extra-files --env-password root@127.0.0.1

na-vm-test target:
    nix run github:nix-community/nixos-anywhere -- --flake .#{{ target }} --vm-test

na-install-btrfs-arm target host:
    nix run github:nix-community/nixos-anywhere -- --build-on-remote --flake .#{{ target }} root@{{ host }}

na-install-btrfs target host:
    nix run github:nix-community/nixos-anywhere --  --flake .#{{ target }} root@{{ host }}
