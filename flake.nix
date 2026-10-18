{
  description = "Factor native development environments";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux" "aarch64-linux" "i686-linux" "armv7l-linux"
        "riscv64-linux" "powerpc64-linux" "powerpc64le-linux"
        "s390x-linux" "loongarch64-linux"
        "x86_64-darwin" "aarch64-darwin"
      ];
    in {
      devShells = nixpkgs.lib.genAttrs systems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in {
          default = import ./shell.nix { inherit pkgs; };
          gtk3 = import ./shell.nix { inherit pkgs; uiBackend = "gtk3"; };
          headless = import ./shell.nix { inherit pkgs; withUI = false; };
          tests = import ./shell.nix { inherit pkgs; withTests = true; };
        });
    };
}
