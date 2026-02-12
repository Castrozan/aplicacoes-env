{ pkgs, ... }:
let
  sshConfigTemplate = pkgs.writeText "ssh-config-template" ''
    Host gitlab.services.betha.cloud
      HostName gitlab.services.betha.cloud
      User git
      IdentityFile ~/.ssh/id_ed25519

    Host gitlab.com
      HostName gitlab.services.betha.cloud
      User git
      IdentityFile ~/.ssh/id_ed25519

    Host github.com
      HostName github.com
      User git
      IdentityFile ~/.ssh/id_rsa
  '';
in
{
  home.activation.deploySshConfig = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      mkdir -p "$HOME/.ssh"
      chmod 700 "$HOME/.ssh"
      if [ ! -f "$HOME/.ssh/config" ]; then
        echo "Deploying default SSH config..."
        cp ${sshConfigTemplate} "$HOME/.ssh/config"
        chmod 600 "$HOME/.ssh/config"
      else
        echo "SSH config already exists, skipping."
      fi
    '';
  };
}
