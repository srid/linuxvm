# How I use my Thinkpad as a web server on the internet
{ config, lib, pkgs, ... }:

let
  # Dedicated user for running internet-exposed services.
  srvUser = "apps";

  obeliskService = name: port: owner: repo: rev: sha256:
    let
      obresult = (import (pkgs.fetchFromGitHub {
        inherit owner repo rev sha256;
      }) {}).exe;
      root = pkgs.runCommand "${name}-service" {}
        ''
        mkdir $out
        cp -r ${obresult}/* $out/
        # Copy deployment config from a private area.
        cp -r ${../../private-config/deployments}/${name}/config $out/
        '';
    in {
      enable = true;
      description = name;
      wantedBy = [ ];
      after = [ "network-online.target" ];
      environment = {};
      serviceConfig = {
        WorkingDirectory = "${root}";
        ExecStart = "${root}/backend -p ${port}";
        Restart = "on-abnormal";
        PrivateTmp = true;
        User = srvUser;
      };
    };
in
{
  # Obelisk apps I expose to the outside world
  systemd.services = {
    slownews =
      obeliskService
        "slownews" "3001" "srid" "slownews"
        "909f6ea0d83ed3f95177d6c8a3f70ffc5ad175b7"
        "10zwnf5z2raphpx3jfml6ry7y0mkpls92wm7ax613p5s18qfagxf";
    MarkdownPreview =
      obeliskService
        "MarkdownPreview" "3002" "srid" "MarkdownPreview"
        "eafa96b9b1b6906f6684bd7ba311d9c3ae85910f"
        "sha256:1axnll107xqwpw20f92n2qvxznz2xqzr1a9x0s24x15mbgbz1qlh";
    slackarchive =
      obeliskService
        "slackarchive" "9002" "srid" "Taut"
        "ef07c2c"
        "1pk99yhb88rgc8siqsqpps1l9qdgsryalbqj37sln0100i549xfz";
  };

  users.extraUsers.${srvUser} = {
    isNormalUser = true;
    uid = 1001;
  };
}
