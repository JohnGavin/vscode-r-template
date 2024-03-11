{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  # nativeBuildInputs is usually what you want -- tools you need to run
  nativeBuildInputs = with pkgs; [
    #nixpkgs-fmt
    #rnix-lsp

    R
    #radianWrapper
    #rPackages.ggplot2
    # rPackages.dplyr rPackages.pacman
#    python3
#    python3Packages.ipython
#    python3Packages.ipykernel
#    python3Packages.scikit-learn
#    python3Packages.matplotlib
  ];
}
