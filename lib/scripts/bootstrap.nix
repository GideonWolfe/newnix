{ config, pkgs, lib, ... }:

let
	keyFile = if config ? sops && config.sops ? age && config.sops.age ? keyFile
		then config.sops.age.keyFile
		else "/var/lib/sops-nix/key.txt";
	ageBin = "${pkgs.age}/bin/age-keygen";
in {
	# Provide a bootstrap helper in PATH for new VMs to print the host AGE public key.
	environment.systemPackages = [
		(pkgs.writeShellScriptBin "bootstrap-age" ''
			#!/usr/bin/env bash
			set -euo pipefail

			KEY_FILE="${keyFile}"
			AGE_BIN="${ageBin}"

			print_header() {
				local title="$1"
				printf '\n=============================================\n'
				printf '%s\n' "$title"
				printf '=============================================\n'
			}

			print_age_key() {
				if [ ! -f "$KEY_FILE" ]; then
					print_header "AGE key not found"
					echo "Expected key at $KEY_FILE"
					echo "If this is first boot, wait a moment or ensure sops-nix generated the key."
					return 1
				fi

				if [ ! -x "$AGE_BIN" ]; then
					print_header "age-keygen not available"
					echo "Cannot find $AGE_BIN"
					echo "Ensure sops/age are installed (they are in systemPackages in your config)."
					return 1
				fi

				local pub
				pub=$("$AGE_BIN" -y "$KEY_FILE")

				print_header "SOPS AGE Public Key"
				echo "Public Key: $pub"
				echo
				echo "Add this to your .sops.yaml:"
				echo "keys:"
				echo "  - &hosts:"
				echo "      - &$(hostname) $pub"
				echo
				echo "Then add $(hostname) to the appropriate creation_rules."
			}

			main() {
				print_age_key || true
			}

			main "$@"
		'')
	];
}
