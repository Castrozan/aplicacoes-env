{
  username,
  version,
  isDarwin,
  ...
}:
{
  home = {
    inherit username;
    homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
    stateVersion = version;
  };
  programs.home-manager.enable = true;
  news.display = "silent";
}
