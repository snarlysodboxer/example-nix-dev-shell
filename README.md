# example-nix-dev-shell

Just experimenting and learning with Nix and Flake based dev shells.

## Setup
* Install Nix.
* Setup Nix Flakes by adding `experimental-features = nix-command flakes` to your Nix config. (Often `~/.config/nix/nix.conf`.)
* Install nix-prefetch-github: `nix-env -iA nixpkgs.nix-prefetch-github`
* Install direnv:
  * `nix-env -iA nixpkgs.direnv`
  * Add `eval "$(direnv hook bash)"` to your `.bashrc`/`.bash_profile`
* Clone this repository and `cd` into it.
* Examine `.envrc`, allow direnv: `direnv allow .`

## Usage
* **With direnv**: Just `cd` into the directory
* **Without direnv**: Start a shell with `nix develop`
* The dev shell will automatically create:
  * `$HOME/.sshw` - SSH configuration file (if it doesn't exist)
  * `./treefmt.toml` - Treefmt configuration file (if it doesn't exist)
* Format code with `treefmt` or `nix run .#formatter.aarch64-darwin` (specify your system)

## Updating the version of sshw
* Get the source hash for the new version: `nix-prefetch-github yinheli sshw --rev v1.1.3 --nix`
* Update in `flake.nix`:
  * `sshwVersion` variable
  * `sshw.src.hash`
* Get the vendor hash: `nix build .#packages.aarch64-darwin.sshw`
  * Copy the vendor hash from the error message to `sshw.vendorHash`
* Verify the build: `nix build .#packages.aarch64-darwin.sshw`

## Notes
* Built on darwin.
* Inconsistent management of configs
  * `.sshw` is created as `~/.sshw` and only created, not updated
  * `treefmt.toml` is created as `./treefmt.toml` and excluded via `.gitignore`
  * Consult with team on a preferred approach.
