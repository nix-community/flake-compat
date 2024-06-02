# flake-compat

> This is a maintained fork of <https://github.com/edolstra/flake-compat>

## Introduction

**[Nix Flakes: Using flakes project from a legacy Nix.](https://nixos.wiki/wiki/Flakes#Using_flakes_project_from_a_legacy_Nix)**

## Usage

To use, add the following to your `flake.nix`:

```nix
inputs.flake-compat.url = "github:nix-community/flake-compat";
```

Example in a `flake.nix` file:

```nix
{
  description = "My first flake";

  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";
  inputs.flake-compat.url = "github:nix-community/flake-compat";

  outputs = { self, nixpkgs, ... }:
    let
      eachSystem = f: nixpkgs.lib.genAttrs self.lib.supportedSystems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      lib.supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell { buildInputs = [ pkgs.hello pkgs.cowsay ]; };
      });
    };
}
```

Update the `flake.lock` to include the hashes for `flake-compat`:

```sh
$ nix --extra-experimental-features "flakes nix-command" flake lock
```
You can say no to potential questions about adding additional substituters,
public keys or other configuration, we just care about the updates to
`flake.lock` here.

Afterwards, create a `default.nix` file containing the following:

```nix
# This file provides backward compatibility to nix < 2.4 clients
{ system ? builtins.currentSystem }:
let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);

  root = lock.nodes.${lock.root};
  inherit (lock.nodes.${root.inputs.flake-compat}.locked) owner repo rev narHash;

  flake-compat = fetchTarball {
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
    sha256 = narHash;
  };

  flake = import flake-compat { inherit system; src = ./.; };
in
flake.defaultNix
```

If you would like a `shell.nix` file, create one containing the above, replacing `defaultNix` with `shellNix`.
