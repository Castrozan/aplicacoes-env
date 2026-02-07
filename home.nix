# Default Home Manager configuration
{
  pkgs,
  pkgsLatest,
  username,
  ...
}: {
  home.username = username;
  home.homeDirectory = "/home/${username}";
  programs.home-manager.enable = true;
  news.display = "silent";

  imports = [
    ./modules/pipx.nix
    ./modules/sdkman.nix
  ];

  home.packages = with pkgs; [
    curl
    pkgsLatest.devenv
    pkgsLatest.direnv
    git
    gnutar
    insomnia
    lens
    postman
    redisinsight
    ripgrep-all
    unzip
    uv
    xclip
    zip

    # nix formatting tools
    alejandra
    nixd
    nixfmt-rfc-style
  ];
}
