{ username, version, ... }:
{
  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = version;
  programs.home-manager.enable = true;
  news.display = "silent";
}
