{ pkgs, lib, config, osConfig, ... }:

{
	# Append personal FreshRSS source configuration to the shared UI config
	programs.newsboat.extraConfig = lib.mkAfter ''
									urls-source "freshrss"
									freshrss-url "https://rss.gideonwolfe.xyz/api/greader.php"
									freshrss-login "gideon"
									freshrss-passwordfile "${osConfig.sops.secrets."freshrss/apikey".path}"
	'';
}
