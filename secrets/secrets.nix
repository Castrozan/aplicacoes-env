let
  lucas-zanoni = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPdOdWOmB7IhmU70+VwgUJ40MHCOwhhrDBn6rq/Fskq/";
  ci-test = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC0/yftnCNp24ay76UpHJPc7CVygSSjq0G5yXywBRR6u";
  all-keys = [
    lucas-zanoni
    ci-test
  ];
in
{
  "npm-auth-token.age".publicKeys = all-keys;
  "gitlab-deploy-token.age".publicKeys = all-keys;
  "aws-credentials.age".publicKeys = all-keys;
}
