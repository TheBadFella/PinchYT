{
  description = "Development environment for pinchflat";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      # nix develop . --command fish
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          lazydocker
          lefthook
          cocogitto
          just
          tailwindcss_4
          docker
          docker-buildx
          docker-compose
          opencode
          typos
          nodejs_22
          yarn
          erlang_28
          beam28Packages.elixir
          beam28Packages.hex
          beam28Packages.expert
        ];
        shellHook = ''
          lefthook install
          cog install-hook
          export COMPOSE_BAKE=true
        '';
      };
    });
}
