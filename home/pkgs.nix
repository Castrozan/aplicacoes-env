{
  pkgs,
  pkgsLatest,
  inputs,
  isLinux,
  ...
}:
{
  home.packages =
    with pkgs;
    [
      bat
      curl
      eza
      git
      gnutar
      unzip
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
    ]
    ++ pkgs.lib.optionals isLinux [
      xclip
    ];
}
