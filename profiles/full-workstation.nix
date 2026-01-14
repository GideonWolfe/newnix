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

        # Full audio/video suite
        ../packages/audio/audio.nix
        ../packages/video/video.nix

        # Art stuff
        ../packages/art/art.nix

        # AI tools for interacting with and running local LLMs
        ../packages/ai/ai.nix
        ../packages/ai/ai-local.nix

        # Pentesting tools
        ../packages/pentesting/pentesting.nix
    ];
}