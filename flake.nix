{
  description = "Neovim plugin for managing tmux pane";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    openspec.url = "github:Fission-AI/OpenSpec";
    openspec.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nixpkgs, openspec, self }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          gossip = pkgs.vimUtils.buildVimPlugin {
            pname = "gossip";
            version = "0.0.1";
            src = self;
          };
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            buildInputs = [
              openspec.packages.${system}.default
              pkgs.stylua
            ];
          };
        }
      );
    };
}
