_: {
  home = {
    shellAliases = {
      eks-login = "aws sso login --profile eks-plataforma-test && aws sso login --profile eks-plataforma-production";
      eks-test = "kubectl config use-context eks-plataforma-test && kubectl config set-context --current --namespace=aplicacoes";
      eks-prod = "kubectl config use-context eks-plataforma-production && kubectl config set-context --current --namespace=aplicacoes";
    };

    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
    };

    sessionPath = [
      "$HOME/.local/bin"
    ];
  };
}
