{ pkgs, ... }:

{
  home.packages = with pkgs.haskellPackages; [

    # Some commonly used tools
    cachix
    pandoc
    hlint

    hoogle
    ormolu
    ghcide
  ];

  home.file = {
    # ghci
    ".ghci".text = ''
      :set prompt "λ> "
    '';

    # coc.vim
    ".config/nvim/coc-settings.json".text = ''
      {
        "languageserver": {
          "neuron": {
            "command": "neuron-language-server",
            "filetypes": ["markdown"]
          },
          "haskell": {
            "command": "ghcide",
            "args": [
              "--lsp"
            ],
            "rootPatterns": [
              ".stack.yaml",
              ".hie-bios",
              "BUILD.bazel",
              "cabal.config",
              "package.yaml"
            ],
            "filetypes": [
              "hs",
              "lhs",
              "haskell"
            ]
          }
        }
      }
      '';
  };
}
