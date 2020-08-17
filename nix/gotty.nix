{ pkgs, ... }:
  let
    # My fork of gotty fixing websocket issue.
    gotty = pkgs.fetchFromGitHub {
      owner = "srid";
      repo = "gotty";
      rev = "a9afda38b263dbaa96a2a4cf9fd19d4c9a27213c";
      sha256 = "15jww883v2a7fd91qvs07k0ixxv4g8va8l55f5kg1qlbfllr2cv0";
    };
  in
  {
    home.packages = with pkgs; [
      (callPackage gotty {})
    ];
  }
