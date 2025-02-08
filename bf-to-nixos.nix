# Convert a brainfuck program to i-use-nixos-btw

# Example usage:
# nix eval --impure --raw --expr 'import ./bf-to-nixos.nix (builtins.readFile ./helloworld.b)' > helloworld.iusenixosbtw

bf:
let
  # Helpers for tokenization of brainfuck
  fromBrainfuck = code: removeInvalid (stringToCharacters code);
  bfSymbols = [ ">" "<" "+" "-" "." "," "[" "]" ];
  iUseNixosBtwSymbols = [ "i" "use" "nix" "and" "nixos" "by" "the" "way" ];
  removeInvalid = list: builtins.filter (a: builtins.any (b: a == b) bfSymbols) list;
  stringToCharacters = s: builtins.genList (p: builtins.substring p 1 s) (builtins.stringLength s);

  bfTokens = fromBrainfuck bf;
  iUseNixosBtwTokens = builtins.replaceStrings (bfSymbols ++ [ " " ]) (iUseNixosBtwSymbols ++ [ " " ]) (builtins.concatStringsSep " " bfTokens);
in
iUseNixosBtwTokens + "\n"
