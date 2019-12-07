with (import <nixos> {});

mkShell {
  buildInputs = with pkgs.nodePackages; [ nodejs purescript grunt-cli bower pulp ];
}
