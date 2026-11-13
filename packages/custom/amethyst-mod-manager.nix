{ amethyst-mod-manager-unfree, sqlite }:

amethyst-mod-manager-unfree.overrideAttrs (old: {
  amethyst_filegraph = old.amethyst_filegraph.overrideAttrs (oldFilegraph: {
    buildInputs = (oldFilegraph.buildInputs or []) ++ [ sqlite ];
  });
})
