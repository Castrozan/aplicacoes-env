{
  pkgs,
  config,
  lib,
  isLinux,
  ...
}:
let
  secretsPath = ../../secrets;
  hasNpmToken = builtins.pathExists (secretsPath + "/npm-auth-token.age");
  npmrcTemplate = pkgs.writeText "npmrc-template" ''
    strict-ssl=false
    email=dev@betha.com.br
    registry=https://nexus3.betha.com.br/repository/npm-all/
  '';
  injectNpmAuthScript = pkgs.writeShellScript "inject-npm-auth" ''
    NPMRC="$HOME/.npmrc"
    SECRET_PATH="${config.age.secrets.npm-auth-token.path}"

    if [ ! -f "$SECRET_PATH" ]; then
      echo "npm-auth-token secret not yet decrypted at $SECRET_PATH, skipping auth injection."
      exit 0
    fi

    TOKEN="$(cat "$SECRET_PATH")"

    if grep -q "_authToken" "$NPMRC" 2>/dev/null; then
      ${pkgs.gnused}/bin/sed -i "s|//nexus3.betha.com.br/repository/npm-all/:_authToken=.*|//nexus3.betha.com.br/repository/npm-all/:_authToken=$TOKEN|" "$NPMRC"
      echo "Updated _authToken in .npmrc"
    else
      echo "//nexus3.betha.com.br/repository/npm-all/:_authToken=$TOKEN" >> "$NPMRC"
      echo "Appended _authToken to .npmrc"
    fi
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

  systemd.user.services = lib.mkIf (hasNpmToken && isLinux) {
    inject-npm-auth = {
      Unit = {
        Description = "Inject npm auth token from agenix secret";
        After = [ "agenix.service" ];
        Requires = [ "agenix.service" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${injectNpmAuthScript}";
        RemainAfterExit = true;
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
