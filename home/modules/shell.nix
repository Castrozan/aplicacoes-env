{ ... }:
{
  home.shellAliases = {
    eks-login = "aws sso login --profile eks-plataforma-test && aws sso login --profile eks-plataforma-production";
    eks-test = "kubectl config use-context eks-plataforma-test && kubectl config set-context --current --namespace=aplicacoes";
    eks-prod = "kubectl config use-context eks-plataforma-production && kubectl config set-context --current --namespace=aplicacoes";
  };

  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";
  };

  home.sessionPath = [
    "$HOME/.local/bin"
  ];
}
