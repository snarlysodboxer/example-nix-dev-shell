{
  description = "sshw and debug tools";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs"; # ensure treefmt-nix uses the same nixpkgs
  };
  outputs = {
    self,
    nixpkgs,
    treefmt-nix,
  }: let
    forAllSystems = nixpkgs.lib.genAttrs ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

    # https://github.com/yinheli/sshw
    sshwVersion = "1.1.2";
    sshw = system:
      nixpkgs.legacyPackages.${system}.buildGoModule {
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

    sshwConfig = pkgs:
      pkgs.writeText ".sshw" ''
        # NOTE: This file is created by the dev shell, edit flake.nix instead
        - name: my-server1
          user: myuser
          host: 192.168.1.35
          port: 22
          password: 123456
        - name: my-server2
          user: myuser
          host: 192.168.1.36
          port: 22
          password: 123456
      '';

    treefmtConfig = pkgs:
      pkgs.writeText "treefmt.toml" ''
        # NOTE: This file is created by the dev shell, edit flake.nix instead

        [formatter.alejandra]
        command = "${pkgs.alejandra}/bin/alejandra"
        includes = ["*.nix"]

        [formatter.alejandra.options]
        # Use default alejandra options
      '';
  in {
    packages = forAllSystems (system: {
      sshw = sshw system;
    });

    formatter = forAllSystems (
      system:
        treefmt-nix.lib.mkWrapper (nixpkgs.legacyPackages.${system}) {
          projectRootFile = "flake.nix";
          programs = {
            alejandra.enable = true;
          };
        }
    );

    devShells = forAllSystems (system: {
      default = nixpkgs.legacyPackages.${system}.mkShellNoCC {
        name = "sshw";
        buildInputs = with nixpkgs.legacyPackages.${system}; [
          dig
          icdiff
          jq
          just
          ripgrep
          treefmt
          (sshw system)
        ];
        shellHook = ''
          # $HOME/.sshw
          if [ ! -f "$HOME/.sshw" ]; then
            cp ${sshwConfig nixpkgs.legacyPackages.${system}} $HOME/.sshw
            echo "Created $HOME/.sshw"
          else
            if ! cmp -s ${sshwConfig nixpkgs.legacyPackages.${system}} "$HOME/.sshw"; then
              echo "Warning: Your $HOME/.sshw is different than the provided config"
              echo "Provided config available at: ${sshwConfig nixpkgs.legacyPackages.${system}}"
            fi
          fi

          # ./treefmt.toml
          if [ ! -f "./treefmt.toml" ]; then
            cp ${treefmtConfig nixpkgs.legacyPackages.${system}} ./treefmt.toml
            echo "Created treefmt.toml"
          else
            if ! cmp -s ${treefmtConfig nixpkgs.legacyPackages.${system}} "./treefmt.toml"; then
              echo "Warning: Your treefmt.toml differs from the provided config"
              echo "Provided config available at: ${treefmtConfig nixpkgs.legacyPackages.${system}}"
            fi
          fi
        '';
      };
    });
  };
}
