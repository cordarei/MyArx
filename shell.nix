with (import ./nix/pin/nixpkgs.nix {});

mkShell {
  buildInputs = with pkgs.nodePackages; [ nodejs purescript bower pulp ];
}
