{ config, pkgs, ... }:

let 
  hostName = "bebe";
  nixpkgs-master = import ../nixos/nixpkgs-master.nix;
in {
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix

      <nixos-hardware/lenovo/thinkpad>
      <nixos-hardware/lenovo/thinkpad/x1>
      <nixos-hardware/lenovo/thinkpad/x1/7th-gen>
      <home-manager/nixos>

      ../nixos/quebec.nix
      ../nixos/nix.nix
      ../nixos/nix-distributed.nix
      ../nixos/gnome.nix
      ../nixos/tmux.nix
      ../nixos/fonts.nix
      ../nixos/syncthing.nix
      ../nixos/docker.nix
      ../nixos/shell.nix

      ../private-config/caches.nix
    ];

  home-manager.users.srid = (import ../nix/home.nix {
    inherit pkgs config hostName;
  } );

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.kernelPackages = pkgs.linuxPackages_testing;
  boot.kernelPackages = let
      customLinuxF = { fetchurl, buildLinux, ... } @ args:
        buildLinux (args // rec {
          version = "5.9.6";
          extraMeta.branch = "5.9";
          modDirVersion = "${version}";

          src = fetchurl {
            url = "https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-${version}.tar.xz";
            sha256 = "0w2kcng09nzk09dwkx4azdfgnwzbd2mz8lyl4j69bwx837z85hbc";
          };
          kernelPatches = [];
        } // (args.argsOverride or {}));
      customLinux = pkgs.callPackage customLinuxF{};
    in 
      pkgs.recurseIntoAttrs (pkgs.linuxPackagesFor customLinux);
  
  # Allow non-free firmware, such as for intel wifi
  hardware = {
    enableRedistributableFirmware = true;
  };
  # Sound
  sound.enable = true;
  # Fingerprint reader
  services.fwupd.enable = true;
  services.fprintd.enable = true;
  security.pam.services.login.fprintAuth = true;
  security.pam.services.xscreensaver.fprintAuth = true;

  networking = {
    hostName = hostName;
    networkmanager = {
      enable = true;
      wifi.powersave = false;
      wifi.scanRandMacAddress = false;
    };
    wireless.networks = ./private-config/wifi.nix;

    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces.wlp0s20f3.useDHCP = true;
  };

  # Set up Wireguard
  networking = {
    nat = {
      enable = true;
    };
    firewall = {
      enable = true;
      allowedUDPPorts = [51820];
    };
    wireguard.interfaces = {
      wg0 = {
        ips = [ "10.100.0.3/24" ];
        listenPort = 51820;
        privateKeyFile = "/home/srid/nix-config/private-config/wireguard/x1c7/private";
        peers = [
          ../nixos/wireguard/peers/facade.nix
          ../nixos/wireguard/peers/p71.nix
        ];
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # google-chrome UI lags on x1c7
    # google-chrome
    chromium

    peek

    mpv
    qmmp  # winamp like

    nixpkgs-master.vscode
    nodejs-12_x  # for vscode remote
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "us";
    # Enable touchpad support.
    libinput.enable = true;
  };

  systemd.services = {
    funprog = 
      let 
        # TODO: properly nixify this
        # - configure API keys
        # - specify output dir as cli param
        # - deal with ./static dir (user_uploads)
        root = "/home/srid/code/zulip-archive";
      in {
        enable = true;
        description = "funprog";
        wantedBy = [ "default.target" ];
        after = [ "network-online.target" ];
        environment = {};
        serviceConfig = {
          WorkingDirectory = "${root}";
          ExecStart = "${root}/result/bin/zulip-archive -w";
          Restart = "on-abnormal";
          PrivateTmp = true;
          User = "srid";
        };
      };

  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.srid = {
     isNormalUser = true;
     extraGroups = [ "wheel" "docker" ];
     shell = pkgs.bash;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.03"; # Did you read the comment?
}