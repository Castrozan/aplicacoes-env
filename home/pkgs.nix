{
  pkgs,
  pkgsLatest,
  inputs,
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
    k9s
    kubectl
    ripgrep-all
    uv

    alejandra
    nixd
    nixfmt-rfc-style

    inputs.agenix.packages.${pkgs.system}.default
  ];
}
