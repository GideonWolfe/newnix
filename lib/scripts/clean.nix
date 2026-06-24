{ pkgs, ... }:
{
	# Provides a helper that runs your four GC commands in sequence, stopping on failure
	environment.systemPackages = [
		(pkgs.writeShellScriptBin "nix-clean" ''
			#!/usr/bin/env bash
			set -euo pipefail

			docker system prune -a -f

			nix-collect-garbage -d
			nix-collect-garbage
			sudo nix-collect-garbage
			sudo nix-collect-garbage -d
			sudo nix-store --optimize
		'')
	];
}