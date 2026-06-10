{
  description = "Cheat Engine for Linux — memory scanner and debugger";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = [
      "x86_64-linux"
    ];

    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });
  in {
    packages = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      cheatengine = pkgs.callPackage ./package.nix {};
      default = self.packages.${system}.cheatengine;
    });

    overlays.default = final: _prev: {
      cheatengine = final.callPackage ./package.nix {};
    };
  };
}
