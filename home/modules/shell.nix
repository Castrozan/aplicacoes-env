_: {
  programs.bash = {
    enable = true;
    initExtra = ''
      HISTCONTROL=ignoreboth:erasedups
      shopt -s histappend
      HISTSIZE=10000
      HISTFILESIZE=20000

      [[ -f ~/.bashrc.local ]] && source ~/.bashrc.local
    '';
  };

  home = {
    shellAliases = {
      eks-login = "aws sso login --profile eks-plataforma-test && aws sso login --profile eks-plataforma-production";
      eks-test = "kubectl config use-context eks-plataforma-test && kubectl config set-context --current --namespace=aplicacoes";
      eks-prod = "kubectl config use-context eks-plataforma-production && kubectl config set-context --current --namespace=aplicacoes";

      ls = "eza";
      l = "eza --classify";
      la = "eza --all";
      ll = "eza --long --all --classify --git --icons";
      lt = "eza --tree --level=2 --icons";

      grep = "grep --color=auto";
      k = "k9s";
      catt = "bat";

      "cd.." = "cd ..";
      "cd." = "cd ..";
    };

    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
    };

    sessionPath = [
      "$HOME/.local/bin"
    ];
  };
}
