# This config represents a fully featured workstation, not limited by storage or hardware

{
    imports = [
        #########
        # Roles #
        #########
        ../roles/base.nix # sets up low level system config
        ../roles/desktop.nix # everything needed to give base desktop experience

        ############
        # Packages #
        ############

        # The full science suite
        ../packages/science/astronomy/astronomy.nix
        ../packages/science/biology/biology.nix
        ../packages/science/chemistry/chemistry.nix
        ../packages/science/data/data.nix
        ../packages/science/engineering/engineering.nix
        ../packages/science/engineering/cad.nix
        ../packages/science/geography/geography.nix
        ../packages/science/math/math.nix
        ../packages/science/medecine/medecine.nix
        ../packages/science/radio/radio.nix

        # The full productivity suite
        ../packages/productivity/art.nix
        ../packages/productivity/calendar-contacts.nix
        ../packages/productivity/ebooks.nix
        ../packages/productivity/finance.nix
        ../packages/productivity/news.nix
        ../packages/productivity/office.nix
        ../packages/productivity/photo.nix
        ../packages/productivity/productivity.nix
        ../packages/productivity/security.nix
        ../packages/productivity/tasks.nix
        ../packages/productivity/web.nix
        ../packages/productivity/wikis.nix

        # The full development suite
        ../packages/development/c.nix
        ../packages/development/java.nix
        ../packages/development/python.nix
        ../packages/development/rust.nix
        ../packages/development/utils.nix

        # Communication apps
        ../packages/comms/comms.nix
        ../packages/comms/discord.nix
        ../packages/comms/irc.nix
        ../packages/comms/matrix.nix
        ../packages/comms/signal.nix
        ../packages/comms/social-media.nix

        # Extra audio/video packages
        ../packages/audio/audio.nix
        ../packages/video/video.nix

        # AI tools for interacting with and running local LLMs
        ../packages/ai/ai.nix
        ../packages/ai/ai-local.nix

        # Pentesting tools
        ../packages/pentesting/pentesting.nix
    ];
}