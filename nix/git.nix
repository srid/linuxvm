{ config, lib, pkgs, ... }:

{
  home.packages = with pkgs; [
  ];
 
  programs.git = {
    package = pkgs.gitAndTools.gitFull;
    enable = true;
    userName = "Sridhar Ratnakumar";
    userEmail = "srid@srid.ca";
    ignores = [ ];
    aliases = {
      co = "checkout";
      ci = "commit";
      cp = "commit -p";
      s = "status";
      st = "status";
      d = "diff";
      pr = "pull --rebase";
      l = "log --graph --pretty='%Cred%h%Creset - %C(bold blue)<%an>%Creset %s%C(yellow)%d%Creset %Cgreen(%cr)' --abbrev-commit --date=relative";
    };
    extraConfig = {
      core.editor = "nvim";
      # Allow keybase git protocol.
      protocol.keybase.allow = "always";
      credential.helper = "store --file ~/.git-credentials";
      pull.rebase = "false";
    };
  };
}
