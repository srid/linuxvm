# NixOS on Thinkpad P71

{ config, pkgs, ... }:

{
  imports =
    [ /etc/nixos/hardware-configuration.nix

      ./thinkpad/hardware.nix
      ./thinkpad/graphics.nix
      ./thinkpad/wireguard.nix
      ./thinkpad/postgresql.nix
      ./thinkpad/webhost.nix
     
      ../nix/base.nix
      ../nix/caches.nix
      ../nix/gui.nix
      ../nix/fonts.nix
      ../nix/dropbox.nix

      # Using GitHub Actions with cachix instead
      # ../nix/ci.nix

      ../private-config
      <home-manager/nixos>
    ];
  home-manager.users.srid = (import ../nix/home.nix "thebeast");

  # EFI boot
  boot = {
    cleanTmpDir = true;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    plymouth.enable = false;
    # Always use the latest available kernel.
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking = {
    hostName = "thebeast";
    networkmanager.enable = true;
  };

  services.openssh = {
    enable = true;
    ports = [22];
  };

  services.netdata = {
    enable = true;
  };

  services.ipfs = {
    # Not using it due to issues with publishing static sites
    enable = false;
    autoMount = true;
  };

  virtualisation.docker.enable = false;
  virtualisation.lxd.enable = true;

  environment.systemPackages = with  pkgs; [
    docker-compose

    # TODO: Use autorandr to switch between modes.
    # For now, doing it manually using arandr.
    #   Using .screenlayout/lgonly.sh when connecting the monitor
    arandr
    autorandr
    acpi
    pulsemixer
    pavucontrol  # GUI version of pulsemixer
    blueman
    ntfs3g

    inkscape
  ];

  users.extraUsers.srid = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "networkmanager" "audio" "docker" "lxd" "ipfs" ];
    shell = pkgs.fish;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
}
