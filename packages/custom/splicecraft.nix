{ lib
, buildPythonApplication
, fetchPypi
, hatchling
, textual
, biopython
, edlib
, primer3
, platformdirs
, pillow
, pyspellchecker
, rich-pixels
# Optional base16 palette (attrset with `#`-prefixed base00..base0F, i.e.
# `config.lib.stylix.colors.withHashtag`). When supplied, the built-in
# `splicecraft-black` Textual theme is repainted to match. Note this only
# themes the app chrome — the DNA base text (hardcoded grey) and per-feature
# annotation colours (semantic: green promoters, yellow CDS, …) are inline
# Rich styles that are deliberately left untouched.
, stylixColors ? null
}:
let
  # SpliceCraft enforces a Textual >= 8.2.8 floor at runtime, but nixpkgs
  # pins 8.2.6; build the required version from the upstream tag.
  textual_8_2_8 = textual.overridePythonAttrs (old: rec {
    version = "8.2.8";
    src = old.src.override {
      tag = "v${version}";
      hash = "sha256-4T+/eD0adPugDP7TCDoDaOe0OrEFskCUadLVEixmTwo=";
    };
  });
in
buildPythonApplication rec {
  pname = "splicecraft";
  version = "1.2.57";
  pyproject = true;

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-qPJ9bzsGLa6Dzb9hLufI6JL1FyhV5m3YwjqKveGMN+A=";
  };

  build-system = [ hatchling ];

  # nixpkgs ships slightly older floors than SpliceCraft pins, and pyhmmer
  # isn't packaged; relax the version pins and drop the optional pyhmmer dep.
  pythonRelaxDeps = [ "platformdirs" ];
  pythonRemoveDeps = [ "pyhmmer" ];

  dependencies = [
    textual_8_2_8
    biopython
    edlib
    primer3
    # pyhmmer is not packaged in nixpkgs; it's an optional dependency and
    # SpliceCraft falls back to a pure-Python BLAST engine without it.
    platformdirs
    pillow
    pyspellchecker
    rich-pixels
  ];

  # Repaint the hardcoded `splicecraft-black` Textual theme from the stylix
  # base16 palette so the app chrome tracks the system theme.
  postPatch = lib.optionalString (stylixColors != null) (
    let c = stylixColors; in ''
      substituteInPlace splicecraft.py \
        --replace-fail 'primary="#0178D4"'    'primary="${c.base0D}"' \
        --replace-fail 'secondary="#004578"'  'secondary="${c.base0C}"' \
        --replace-fail 'warning="#ffa62b"'    'warning="${c.base0A}"' \
        --replace-fail 'error="#ba3c5b"'      'error="${c.base08}"' \
        --replace-fail 'success="#4EBF71"'    'success="${c.base0B}"' \
        --replace-fail 'accent="#ffa62b"'     'accent="${c.base0E}"' \
        --replace-fail 'foreground="#e0e0e0"' 'foreground="${c.base05}"' \
        --replace-fail 'background="#000000"' 'background="${c.base00}"' \
        --replace-fail 'surface="#1c1c1c"'    'surface="${c.base01}"' \
        --replace-fail 'panel="#000000"'      'panel="${c.base00}"'
    ''
  );

  # No importable top-level module; SpliceCraft ships as flat scripts.
  pythonImportsCheck = [ ];

  # Tests need heavy fixtures/network and aren't shipped runnable.
  doCheck = false;

  meta = with lib; {
    description =
      "Terminal-based plasmid map viewer, sequence editor, and cloning/mutagenesis workbench";
    homepage = "https://github.com/Binomica-Labs/SpliceCraft";
    license = licenses.mit;
    mainProgram = "splicecraft";
  };
}
