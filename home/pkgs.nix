{
  pkgs,
  pkgsLatest,
  ...
}:
{
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
