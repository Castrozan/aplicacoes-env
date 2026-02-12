{
  username,
  version,
  ...
}:
{
  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = version;
  };
  programs.home-manager.enable = true;
  news.display = "silent";
}
