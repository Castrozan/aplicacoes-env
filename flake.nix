{
  description = "Nix and Home Manager configuration for team Aplicações";

  inputs = {
    # Nixpkgs 25.05 for stable packages
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    # Nixpkgs unstable for packages that are not yet in the stable channel
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Nixpkgs latest for bleeding edge packages
    # $ nix flake update nixpkgs-latest
    nixpkgs-latest.url = "github:NixOS/nixpkgs/nixos-unstable";
    # Home Manager for managing user configurations
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nixpkgs-latest,
    home-manager,
    ...
  }: let
    # List of user configurations
    users = [
      {
        username = "lucas.zanoni";
      }
      # To add more users, append another record here:
      # { username = "cleber"; }
    ];

    # Common extra args (all flake inputs)
    specialArgs = {inherit inputs;};

    # Function to build each user's homeConfiguration
    userHomeConfig = user: let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
      pkgsLatest = import nixpkgs-latest {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      name = "${user.username}@${system}";
      value = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs =
          specialArgs
          // {
            username = user.username;
            pkgsUnstable = pkgsUnstable;
            pkgsLatest = pkgsLatest;
          };
        modules = [
          ./home.nix
          # User-specific packages
          ./users/${user.username}/default.nix
        ];
      };
    };
  in {
    homeConfigurations = builtins.listToAttrs (map userHomeConfig users);
  };
}
