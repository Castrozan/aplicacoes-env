{ ... }:
{
  programs.ssh = {
    enable = true;
    matchBlocks = {
      "gitlab.services.betha.cloud" = {
        hostname = "gitlab.services.betha.cloud";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
      };
      "gitlab.com" = {
        hostname = "gitlab.services.betha.cloud";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
      };
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_rsa";
      };
    };
  };
}
