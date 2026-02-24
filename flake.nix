{
  description = ''
    Standalone Home Manager flake for team Aplicações

    Forget everything you know about nix, this is just a framework to configure apps and dotfiles.
  '';

  # Inputs declare package definitions and modules to fetch from the internet
  inputs = {
    # For stable package definitions
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # For packages not yet in stable nixpkgs
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # For latest bleeding edge packages - daily* updated with: $ nix flake update nixpkgs-latest
    nixpkgs-latest.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      # follows = makes home-manager use the same nixpkgs as this flake
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # External flake for encrypted secrets management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Outputs are what this flake provides: home configurations and reusable modules
  outputs =
    inputs@{
      nixpkgs,
      nixpkgs-latest,
      home-manager,
      agenix,
      ...
    }:
    # let-in notation to declare local variables for the output scope
    let
      system = builtins.currentSystem; # Auto-detect system architecture (requires --impure flag)
      username = builtins.getEnv "USER"; # Detect current user (requires --impure flag)
      isLinux = builtins.match ".*-linux" system != null;
      isDarwin = builtins.match ".*-darwin" system != null;
      version = "25.11";
      # Configure nixpkgs then attribute it to pkgs at the same time
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pkgsLatest = import nixpkgs-latest {
        inherit system;
        config.allowUnfree = true;
      };
      # Variables injected into every module via dependency injection (specialArgs)
      specialArgsBase = {
        inherit
          pkgs
          pkgsLatest
          version
          inputs
          username
          isLinux
          isDarwin
          ;
      };
    in
    {
      # homeConfigurations.${username}@${system}
      # is a standalone Home Manager configuration for a user and system architecture
      # Applied with: make switch (or nix run home-manager -- switch --flake .#"$USER@x86_64-linux" --impure)
      homeConfigurations."${username}@${system}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = specialArgsBase;
        modules = [
          agenix.homeManagerModules.default
          ./home/core.nix
          ./home/modules.nix
          ./home/pkgs.nix
        ];
      };

      # Reusable modules for consuming this flake from personal dotfiles
      homeManagerModules = {
        packages = ./home/pkgs.nix;
        modules = ./home/modules.nix;
        secrets = ./home/modules/agenix.nix;
        default = {
          imports = [
            ./home/pkgs.nix
            ./home/modules.nix
          ];
        };
      };
    };
}
