{
  description = "sshw and debug tools";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };
  outputs = { self, nixpkgs }: let
    pkgs = nixpkgs.legacyPackages.aarch64-darwin.pkgs;
  in
  {
    devShells.aarch64-darwin.default = pkgs.mkShellNoCC {
      name = "sshw";
      buildInputs = with pkgs; [
        dig
        icdiff
        jq
        just
        ripgrep
      ];
    };
  };
}
