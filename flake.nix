{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix";

    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";

    ags.url = "github:Aylur/ags";

    mithril-shell.url = "github:andreashgk/mithril-shell";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    user = "korazza";
    host = "desktop";
    language = "it_IT";
    timeZone = "Europe/Rome";

    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations.${host} = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit
          system
          user
          host
          language
          timeZone
          inputs
          ;
      };
      modules = [
        ./hosts/${host}/configuration.nix
        inputs.stylix.nixosModules.stylix
        {nixpkgs.overlays = [inputs.hyprpanel.overlay];}
      ];
    };

    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
  };
}
