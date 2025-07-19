{
  pkgs,
  pkgsLatest,
  username,
  homeVersion,
  ...
}:
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = homeVersion;
  programs.home-manager.enable = true;
  news.display = "silent";

  imports = [
    # ./modules/m2.nix
    ./modules/pipx.nix
    ./modules/sdkman.nix
  ];

  home.packages = with pkgs; [
    brave
    pkgsLatest.claude-code
    pkgsLatest.code-cursor
    curl
    pkgsLatest.devenv
    pkgsLatest.direnv
    pkgsLatest.gemini-cli
    git
    gnutar
    insomnia
    lazydocker
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
