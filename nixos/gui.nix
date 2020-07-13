{ config, pkgs, ...}:

{
  # Google Chrome ulimit upping
  # https://bugs.chromium.org/p/chromium/issues/detail?id=362603#c28
  security.pam.loginLimits = [
    { domain = "*"; item = "nofile"; type = "-"; value = "65536"; }
  ];

  services.compton = {
    enable = true;
    shadow = true;
    inactiveOpacity = 1.0;
  };

  services.xserver = {
    enable = true;

    layout = "us";
    xkbOptions = "grp:alt_space_toggle, ctrl:swapcaps";

    displayManager = {
      hiddenUsers = [ "apps" ];
      gdm = {
        enable = true;
      };
    };

    windowManager.i3.enable = true;

    desktopManager = {
      # To make home-manager's i3 available in system X session
      # https://discourse.nixos.org/t/opening-i3-from-home-manager-automatically/4849/8
      session = [
        { 
          name = "home-manager";
          start = ''
            ${pkgs.runtimeShell} $HOME/.hm-xsession &
            waitPID=$!
          '';
        }
      ];
    };

    desktopManager.plasma5 = {
      enable = false;
    };

    desktopManager.gnome3 = {
      enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    asciinema

    # To launch peek, C-p peek
    # C+S+<space> to make it floaitng window
    # Postiion window and begin record
    # C+S+4 to move it hidden i3 workspace
    # When recording is done, hit C+4 to bring it back
    # Stop recording.
    peek
    simplescreenrecorder

    vscode
    google-chrome
    xorg.xbacklight
    xorg.xf86videointel
    xorg.xprop
    xsel
  ];
}
