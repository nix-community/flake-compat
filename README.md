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

  outputs = { self, nixpkgs, flake-compat }:
    let
      eachSystem = f: nixpkgs.lib.genAttrs lib.systems.flakeExposed (system: f nixpkgs.legacyPackages.${system});
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

Afterwards, create a `default.nix` file containing the following:

```nix
{ system ? builtins.currentSystem }:
(import
  (
    let
      lock = builtins.fromJSON (builtins.readFile ./flake.lock);
      inherit (lock.nodes.flake-compat.locked) owner repo rev narHash;
    in
    fetchTarball {
      url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
      sha256 = narHash;
    }
  )
  { src = ./.; inherit system; }
).defaultNix
```

If you would like a `shell.nix` file, create one containing the above, replacing `defaultNix` with `shellNix`.
