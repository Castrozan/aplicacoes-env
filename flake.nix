{
  description = "Nix and Home Manager configuration for team Aplicações";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-latest.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-latest,
      home-manager,
      ...
    }:
    let
      # List of user configurations
      users = [
        {
          username = "lucas.zanoni";
          system = "x86_64-linux";
          homeVersion = "23.11";
        }
        # To add more users, append another record here:
        # { username = "alice"; system = "aarch64-linux"; homeVersion = "24.05"; }
      ];

      # Common extra args (all flake inputs)
      specialArgs = { inherit inputs; };

      # Function to build each user's homeConfiguration
      userHomeConfig =
        user:
        let
          system = user.system;
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          pkgsLatest = import nixpkgs-latest {
            inherit system;
            config.allowUnfree = true;
          };
        in
        {
          name = "${user.username}@${system}";
          value = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            extraSpecialArgs = specialArgs // {
              username = user.username;
              homeVersion = user.homeVersion;
              pkgsLatest = pkgsLatest;
            };
            modules = [ ./home.nix ];
          };
        };
    in
    {
      homeConfigurations = builtins.listToAttrs (map userHomeConfig users);
    };
}
