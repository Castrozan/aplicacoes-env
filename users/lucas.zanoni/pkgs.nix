{
  pkgs,
  pkgsLatest,
  ...
}: {
  home.packages = with pkgs; [
    brave
    pkgsLatest.claude-code
    pkgsLatest.code-cursor
    pkgsLatest.gemini-cli
    lazydocker
  ];
}
