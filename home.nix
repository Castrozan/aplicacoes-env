{
  pkgs,
  pkgsLatest,
  username,
  ...
}:
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
  news.display = "silent";

  imports = [
    ./modules/npmrc.nix
  ];

  home.packages = with pkgs; [
    curl
    git
    gnutar
    unzip
    xclip
    zip

    pkgsLatest.devenv
    pkgsLatest.direnv

    awscli2
    docker-compose
    insomnia
    k9s
    kubectl
    postman
    redisinsight
    ripgrep-all
    uv

    alejandra
    nixd
    nixfmt-rfc-style
  ];
}
