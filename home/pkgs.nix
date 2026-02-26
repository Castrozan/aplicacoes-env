{
  pkgs,
  pkgsLatest,
  ...
}:
{
  home.packages = with pkgs; [
    # bat
    # curl
    # eza
    # git
    # gnutar
    # unzip
    # zip
    # awscli2
    # docker-compose
    # k9s
    # kubectl
    # ripgrep-all
    # uv
    # code
    # claude-code
    # codex
    # opencode
    # gemini-cli

    # Dev environments with nix https://devenv.sh/
    pkgsLatest.devenv
    # Nix formatting tools
    alejandra
    nixd
    nixfmt-rfc-style
  ];
}
