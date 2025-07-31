{
  description = "sshw and debug tools";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
  };
  outputs = { self, nixpkgs }: let
    forAllSystems = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

    # https://github.com/yinheli/sshw
    sshwVersion = "1.1.2";
    sshw = system: nixpkgs.legacyPackages.${system}.buildGoModule {
      pname = "sshw";
      version = sshwVersion;
      src = nixpkgs.legacyPackages.${system}.fetchFromGitHub {
        owner = "yinheli";
        repo = "sshw";
        rev = "v${sshwVersion}";
        hash = "sha256-Qr8ICRab85Gse5xb3qECjPNehj86yhvF68l2zSFCG/s=";
      };
      vendorHash = "sha256-xI605rup1XjFZj8HH6p3n0mnS1NaVVS2ZMkGuK/QRuY=";
      meta = with nixpkgs.lib; {
        description = "SSH client wrapper for automatic login";
        homepage = "https://github.com/yinheli/sshw";
        license = licenses.mit;
      };
    };
  in
  {
    packages = forAllSystems (system: {
      sshw = sshw system;
    });

    devShells = forAllSystems (system: {
      default = nixpkgs.legacyPackages.${system}.mkShellNoCC {
        name = "sshw";
        buildInputs = with nixpkgs.legacyPackages.${system}; [
          dig
          icdiff
          jq
          just
          ripgrep
          (sshw system)
        ];
      };
    });
  };
}
