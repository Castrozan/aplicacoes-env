{ pkgs, username, ... }:
{
  home.packages = with pkgs; [
    delta
  ];

  programs.git = {
    enable = true;
    userName = username;
    userEmail = "${username}@betha.com.br";
    extraConfig = {
      init.defaultBranch = "master";
      push.autoSetupRemote = true;
      pull.rebase = true;
      core.pager = "delta";
      interactive.diffFilter = "delta --color-only";
      delta = {
        navigate = true;
        line-numbers = true;
      };
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };
}
