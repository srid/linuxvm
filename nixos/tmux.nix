{ config, pkgs, lib, ...}:

{ 
  programs.tmux = {
    enable = true;
    shortcut = "a";
    aggressiveResize = true;
    baseIndex = 1;
    newSession = true;
    # Stop tmux+escape craziness.
    escapeTime = 0;

    extraConfig = ''
      # Mouse works as expected
      set-option -g mouse on

      # easy-to-remember split pane commands
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind c new-window -c "#{pane_current_path}"
    '';
  };
}
