{
  pkgs,
  username,
  ...
}:
let
  gitconfigTemplate = pkgs.writeText "gitconfig-template" ''
    [user]
      name = ${username}
      email = ${username}@betha.com.br
    [init]
      defaultBranch = master
    [push]
      autoSetupRemote = true
    [pull]
      rebase = true
    [core]
      pager = delta
    [interactive]
      diffFilter = delta --color-only
    [delta]
      navigate = true
      line-numbers = true
    [merge]
      conflictstyle = diff3
    [diff]
      colorMoved = default
  '';
in
{
  home.packages = with pkgs; [
    delta
  ];

  home.activation.deployGitconfig = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      if [ ! -f "$HOME/.gitconfig" ]; then
        echo "Deploying default .gitconfig..."
        cp ${gitconfigTemplate} "$HOME/.gitconfig"
        chmod 644 "$HOME/.gitconfig"
      else
        echo ".gitconfig already exists, skipping."
      fi
    '';
  };
}
