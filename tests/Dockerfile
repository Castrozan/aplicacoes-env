# Quick evaluation test: Ubuntu 24.04 + Nix
# Validates flake evaluation without full deployment.

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ARG TEST_USER=testuser
ENV USER=${TEST_USER}

RUN apt-get update -qq && \
    apt-get install -y -qq curl xz-utils sudo git && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
    sh -s -- install linux --no-confirm --init none

ENV PATH="/nix/var/nix/profiles/default/bin:${PATH}"

WORKDIR /src
COPY . .

RUN nix flake update --accept-flake-config 2>/dev/null || nix flake update

CMD ["bash", "-c", "\
  set -e && \
  echo '=== Environment ===' && \
  cat /etc/os-release | head -3 && \
  nix --version && \
  echo '' && \
  echo '=== Nix flake metadata ===' && \
  nix flake metadata && \
  echo '' && \
  echo '=== Checking flake outputs ===' && \
  CONFIGS=$(nix eval .#homeConfigurations --impure --apply 'x: builtins.attrNames x' --json) && \
  echo \"homeConfigurations: $CONFIGS\" && \
  echo '' && \
  echo '=== Evaluating home config ===' && \
  nix eval '.#homeConfigurations.\"'$USER'@x86_64-linux\".config.home.username' --impure --json && \
  nix eval '.#homeConfigurations.\"'$USER'@x86_64-linux\".config.home.homeDirectory' --impure --json && \
  echo '' && \
  echo '=== Building activation package (dry-run eval) ===' && \
  nix eval '.#homeConfigurations.\"'$USER'@x86_64-linux\".activationPackage.drvPath' --impure --json && \
  echo '' && \
  echo '=== All checks passed on Ubuntu ===' \
"]
