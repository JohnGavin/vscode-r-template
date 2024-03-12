{ pkgs ? import <nixpkgs> { } }:
let
  # spkgs = import <nixpkgs> { };
 # pkgs = import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/f945939fd679284d736112d3d5410eb867f3b31c.tar.gz") {};
 rpkgs = builtins.attrValues {
  inherit (pkgs.rPackages) Cairo devtools dplyr fs ggplot2 glue goodpractice here httpgd lmtest lubridate pacman patchwork purrr quarto readr reticulate rmarkdown roll rvest sandwich stringr tarchetypes targets tibbletime tidyfit tidyr visNetwork;
};
pypkgs = [ # pkgs.python311
    (pkgs.python3.withPackages (python-pkgs: [
      python-pkgs.numpy # not installed by pandas!?
      python-pkgs.pandas
      # python-pkgs.polars
      python-pkgs.seaborn
      python-pkgs.requests
    ]))];

 git_archive_pkgs = [(pkgs.rPackages.buildRPackage {
    name = "rix";
    src = pkgs.fetchgit {
      url = "https://github.com/b-rodrigues/rix";
      branchName = "master";
      rev = "6dcc9bcb10dcd1baaa9a7d83bab5d1445f231455";
      sha256 = "sha256-Gn0R4ND4AHE8wjtEEyHFI4Gl0p39nlb26VLRW16kClU=";
    };
    propagatedBuildInputs = builtins.attrValues {
      inherit (pkgs.rPackages) codetools httr jsonlite sys;
    };
  })
(pkgs.rPackages.buildRPackage {
    name = "rsims";
    src = pkgs.fetchgit {
      url = "https://github.com/Robot-Wealth/rsims/";
      branchName = "main";
      rev = "5ecb5cb2cc113d0b420f18a3329ee52e283f84c0";
      sha256 = "sha256-USKhpYbNMNkiGweMCUZsGW1Ad3KQ9GBj0txn442GBkQ=";
    };
    propagatedBuildInputs = builtins.attrValues {
      inherit (pkgs.rPackages) dplyr tibble tidyr stringr magrittr ggplot2 lubridate here roll Rcpp;
    };
  }) ];
  system_packages = builtins.attrValues {
  inherit (pkgs)
    R quarto radianWrapper
    python3
    glibcLocales
    # nix # why nix?
     lazygit # httpgd is fully functional without cairo Configuration failed to find cairo system library.
    nano oh-my-zsh openssl
    util-linux # TODO: whereis find missing?
    cairo
    # python3-pandas
    # rstudioWrapper
  ;
 };
  in
  pkgs.mkShell {
    LOCALE_ARCHIVE = if pkgs.system == "x86_64-linux" then  "${pkgs.glibcLocales}/lib/locale/locale-archive" else "";
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";

    buildInputs = [ git_archive_pkgs rpkgs
    system_packages pypkgs
    ];

# default 'result' is in / (created by root)
# CMD ['nix-shell /default.nix']
# switch to USER vscode /home/vscode
#   work from /workspaces/vscode-r-template/
# Create non-root USER vscode /home/vscode
# https://discourse.nixos.org/t/how-to-add-a-non-root-user-when-building-a-docker-image-with-nix/22883/6
  runAsRoot = ''
    #!${pkgs.runtimeShell}
    ${pkgs.dockerTools.shadowSetup}
    groupadd -r vscode
    useradd -r -g vscode vscode
    #  groupadd --system nginx
    #  useradd --system --gid nginx nginx
    echo "vscode:vscode" | chpasswd
    mkdir /home/vscode
    chown vscode:vscode -R /home/vscode
  '';

  }
