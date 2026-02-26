# Time Aplicacoes - Ambiente de Desenvolvimento

Ambiente de desenvolvimento declarativo para o time Aplicacoes usando Nix flakes e Home Manager. Esqueça tudo que você sabe sobre Nix — isso é apenas um framework para configurar aplicativos e dotfiles. Cada desenvolvedor faz fork deste repositório e personaliza seus próprios pacotes.

O ponto de entrada é `flake.nix`. Ele define inputs (de onde vêm os pacotes), outputs (a configuração home aplicada ao seu usuário) e módulos reutilizáveis para consumo externo. Leia de cima a baixo — está comentado para explicar cada seção.

## Início Rápido

### 1. Instalar o Nix

```bash
curl -L https://nixos.org/nix/install | sh -s -- --daemon
```

### 2. Habilitar flakes

```bash
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
```

### 3. Clonar e aplicar

```bash
git clone https://github.com/Castrozan/aplicacoes-env ~/aplicacoes-env
cd ~/aplicacoes-env
git config core.hooksPath .githooks
make switch
```

`make switch` detecta o sistema atual e executa `nix run home-manager -- switch --flake .#"$USER@$SYSTEM" --impure`. A flag `--impure` é necessária porque `flake.nix` usa `builtins.getEnv "USER"` e `builtins.currentSystem` para detectar automaticamente o nome de usuário e a arquitetura do sistema no momento da avaliação. Isso significa que o mesmo flake funciona tanto no Linux (`x86_64-linux`) quanto no macOS (`aarch64-darwin`, `x86_64-darwin`) sem alterações. No macOS, pacotes exclusivos do Linux como `xclip` são excluídos e serviços systemd são ignorados.

## Como funciona

`flake.nix` declara três seções:

**Inputs** buscam definições de pacotes e módulos da internet. Existem três canais de pacotes — `nixpkgs` (estável, nixos-25.11) para a maioria dos pacotes, `nixpkgs-unstable` para pacotes ainda não disponíveis no estável, e `nixpkgs-latest` para versões mais recentes (atualize independentemente com `nix flake update nixpkgs-latest`). Home Manager e agenix também são declarados como inputs, ambos seguindo o mesmo nixpkgs para evitar avaliações duplicadas.

**Outputs** definem o que este flake fornece. A saída principal é uma entrada `homeConfigurations` que constrói uma configuração standalone do Home Manager para o usuário atual. Ela compõe três arquivos de módulo: `home/core.nix` (nome de usuário, diretório home, versão de estado), `home/pkgs.nix` (todos os pacotes instalados) e `home/modules.nix` (importa tudo de `home/modules/`). Todos os módulos recebem variáveis compartilhadas (`pkgs`, `pkgsLatest`, `version`, `inputs`, `username`) via injeção de dependência através de `specialArgs`.

**homeManagerModules** expõem partes individuais para consumo por flakes pessoais de dotfiles — você pode importar apenas pacotes, apenas módulos, apenas secrets, ou o padrão (pacotes + módulos).

## Módulos

Os módulos ficam em `home/modules/`. Cada um configura uma ferramenta ou serviço específico usando o padrão copiar-se-não-existe via `home.activation` — os arquivos são implantados na primeira ativação mas nunca sobrescritos, permitindo que os usuários os modifiquem localmente após a configuração.

| Módulo | O que faz |
|--------|-----------|
| `git.nix` | `.gitconfig` com delta pager, email betha, rebase no pull |
| `ssh.nix` | `~/.ssh/config` para gitlab.services.betha.cloud e github.com |
| `shell.nix` | `programs.bash` com configuração de histórico, aliases do time (eza, bat, k9s, EKS), adições ao PATH, sourcing de `~/.bashrc.local` |
| `npmrc.nix` | `.npmrc` com registry nexus, mais serviço systemd `inject-npm-auth` para injeção de token |
| `agenix.nix` | Secrets criptografados descriptografados no login via serviço systemd do usuário |

## Gerenciamento de Secrets

Secrets criptografados via [agenix](https://github.com/ryantm/agenix). O módulo Home Manager do agenix executa um serviço systemd de usuário no login (não durante `home-manager switch`) que descriptografa arquivos `.age` para `$XDG_RUNTIME_DIR/agenix/`. O serviço `inject-npm-auth` executa após o agenix para adicionar `_authToken` ao `.npmrc`.

`secrets/secrets.nix` lista quais chaves públicas podem descriptografar cada secret. Para adicionar um novo secret: `agenix -e secrets/new-secret.age`.

## Comandos

```bash
make switch       # Aplicar configuração ao usuário atual
make test         # Executar todos os testes (avaliação + deploy completo)
make test-eval    # Rápido: apenas avaliação do flake
make test-full    # Completo: ativação do home-manager no Ubuntu 24.04
make shell        # Container interativo para debug
make lint         # Verificação statix + deadnix + nixfmt
make fmt          # Formatar arquivos nix
```

## Consumindo como Módulo Home Manager

Este flake expõe `homeManagerModules` para uso em dotfiles pessoais:

```nix
# Nos inputs do seu flake.nix:
aplicacoes-env.url = "github:Castrozan/aplicacoes-env";

# Nos seus módulos home-manager:
imports = [ inputs.aplicacoes-env.homeManagerModules.default ];

# Ou importe seletivamente:
imports = [
  inputs.aplicacoes-env.homeManagerModules.packages  # apenas pacotes
  inputs.aplicacoes-env.homeManagerModules.modules    # apenas módulos (git, ssh, shell, npmrc, agenix)
  inputs.aplicacoes-env.homeManagerModules.secrets    # apenas configuração de secrets agenix
];
```

O flake consumidor deve fornecer `pkgs`, `pkgsLatest`, `version`, `inputs` e `username` via `extraSpecialArgs`.

## Verificações de Pre-Push

Configurado via `.githooks/pre-push.sh`. Pule com `SKIP_HOOKS=1 git push`.
