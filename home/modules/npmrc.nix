{ pkgs, ... }:
let
  npmrcTemplate = pkgs.writeText "npmrc-template" ''
    strict-ssl=false
    email=dev@betha.com.br
    registry=https://nexus3.betha.com.br/repository/npm-all/
  '';
in
{
  home.activation.deployNpmrc = {
    after = [ "writeBoundary" ];
    before = [ ];
    data = ''
      if [ ! -f "$HOME/.npmrc" ]; then
        echo "Deploying default .npmrc..."
        cp ${npmrcTemplate} "$HOME/.npmrc"
        chmod 644 "$HOME/.npmrc"
      else
        echo ".npmrc already exists, skipping."
      fi
    '';
  };
}
