{
  pkgs,
  inputs,
  username,
  isDarwin,
  ...
}:
let
  secretsPath = ../../secrets;
  hasNpmToken = builtins.pathExists (secretsPath + "/npm-auth-token.age");
  hasGitlabDeployToken = builtins.pathExists (secretsPath + "/gitlab-deploy-token.age");
  hasAwsCredentials = builtins.pathExists (secretsPath + "/aws-credentials.age");
in
{
  home.packages = [
    inputs.agenix.packages.${pkgs.system}.default
  ];

  age.identityPaths =
    let
      homePrefix = if isDarwin then "/Users" else "/home";
    in
    [ "${homePrefix}/${username}/.ssh/id_ed25519" ];

  age.secrets =
    { }
    // (if hasNpmToken then { npm-auth-token.file = secretsPath + "/npm-auth-token.age"; } else { })
    // (
      if hasGitlabDeployToken then
        { gitlab-deploy-token.file = secretsPath + "/gitlab-deploy-token.age"; }
      else
        { }
    )
    // (
      if hasAwsCredentials then { aws-credentials.file = secretsPath + "/aws-credentials.age"; } else { }
    );
}
