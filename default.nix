# Evaluate a i-use-nixos-btw program or a brainfuck program
#
# Example usage:
# nix eval --impure --raw --option max-call-depth 100000 --expr 'import ./. { code = (builtins.readFile ./helloworld.iusenixosbtw); }'
#
# It is not always necessary to increase the max-call-depth, howerver sometimes it may be needed.

{ code
, inputs ? [ ]
, brainfuck ? false
, limit ? true
, limitNum ? 65535
, abortOnDataPointerLimit ? false
}:
let
  # Ascii conversion for output. From 0 to 255.
  ascii = builtins.fromJSON (builtins.readFile ./ascii.json);

  # Instruction symbols
  i =
    if brainfuck then {
      RIGHT = ">";
      LEFT = "<";
      INC = "+";
      DEC = "-";
      OUT = ".";
      IN = ",";
      START = "[";
      END = "]";
    } else {
      RIGHT = "i";
      LEFT = "use";
      INC = "nix";
      DEC = "and";
      OUT = "nixos";
      IN = "by";
      START = "the";
      END = "way";
    };

  # Helpers for tokenization of i-use-nixos-btw and brainfuck
  fromIUseNixosBtw = code: builtins.filter (e: builtins.isString e && e != "") (builtins.split "[[:space:]]+" (builtins.replaceStrings upperChars lowerChars code));
  lowerChars = stringToCharacters "abcdefghijklmnopqrstuvwxyz";
  upperChars = stringToCharacters "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  fromBrainfuck = code: removeInvalid (stringToCharacters code);
  validChars = [ ">" "<" "+" "-" "." "," "[" "]" ];
  removeInvalid = list: builtins.filter (a: builtins.any (b: a == b) validChars) list;
  stringToCharacters = s: builtins.genList (p: builtins.substring p 1 s) (builtins.stringLength s);

  tokens = (if brainfuck then fromBrainfuck else fromIUseNixosBtw) code;

  # Create a sublist from a list. Both bounds (start and end) are inclusive.
  sublist =
    start:
    end:
    list:
    builtins.genList
      (n: builtins.elemAt list (n + start))
      (end - start + 1);

  # Increment the instruction pointer
  incIp = state: state // { ip = state.ip + 1; };

  # Update one element of a list at the specified data pointer
  updateAtDp = update: dp: list:
    let
      len = builtins.length list;
      elemAt = index: if index >= len then 0 else builtins.elemAt list index;
    in
    builtins.genList (index: if index == dp then update (elemAt index) else elemAt index) (if dp < len then len else dp + 1);

  # Increment and decrement the cells at the data pointer
  incAtDp = updateAtDp (x: if x == 255 then 0 else x + 1);
  decAtDp = updateAtDp (x: if x == 0 then 255 else x - 1);

  # Get an element of a list, returning the element if it exists or 0 if it doesn't
  elemAt = list: index: if index >= builtins.length list then 0 else builtins.elemAt list index;

  # Remove the last element of a list
  pop = list:
    let
      len = builtins.length list;
    in
    builtins.genList (i: builtins.elemAt list i) (len - 1);

  # Remove the first element of a list. builtins.tail also exists, but it has a warning not to use it.
  shift = list:
    let
      len = builtins.length list;
    in
    builtins.genList (i: builtins.elemAt list (i + 1)) (len - 1);

  # Execute a list of tokens from the initial state. Recursive function for loops.
  exec = initial-state: instructions: builtins.foldl'
    (state: ins: incIp (if state.isSkipping then
      if ins == i.START then state // { sp = state.sp ++ [ state.ip ]; } else
      if ins == i.END then
        if builtins.length state.sp == state.originalLength then state // { isSkipping = false; } else state // { sp = pop state.sp; }
      else state
    else
      if ins == i.RIGHT then state // { dp = assert !limit || state.dp != limitNum || !abortOnDataPointerLimit || abort "Data pointer too high."; if state.dp == limitNum then limitNum else state.dp + 1; } else
      if ins == i.LEFT then state // { dp = assert state.dp != 0 || !abortOnDataPointerLimit || abort "Negative data pointer."; if state.dp == 0 then 0 else state.dp - 1; } else
      if ins == i.INC then state // { data = incAtDp state.dp state.data; } else
      if ins == i.DEC then state // { data = decAtDp state.dp state.data; } else
      if ins == i.OUT then state // (with state; { output = output ++ [ (elemAt data dp) ]; }) else
      if ins == i.IN then assert builtins.length state.inputs != 0 || abort "No more inputs to read."; state // {
        data = updateAtDp (x: builtins.head state.inputs) state.dp state.data;
        inputs = shift inputs;
      } else if ins == i.START then
        if (elemAt state.data state.dp) == 0 then state // {
          isSkipping = true;
          originalLength = builtins.length state.sp;
        } else state // {
          sp = state.sp ++ [ state.ip ];
        }
      else if ins == i.END then
        if (elemAt state.data state.dp) == 0 then state // {
          sp = pop state.sp;
        } else
          assert builtins.length state.sp != 0 || abort "Incorrect parenthesis: attempt at closing with ${i.END} while never having opened with ${i.START}.";
          let
            res = exec
              (state // {
                ip = 0;
                sp = [ ];
              })
              (sublist (builtins.elemAt state.sp ((builtins.length state.sp) - 1)) state.ip instructions);
          in
          assert builtins.length res.sp == 0 || abort "Incorrect parenthesis: this specific error should never happen."; res // {
            inherit (state) ip;
            sp = pop state.sp;
          }
      else abort "Unknown instruction"
    ))
    initial-state
    instructions;

  executed = exec
    {
      ip = 0; # Instruction pointer
      dp = 0; # Data pointer
      sp = [ ]; # Stack to remember indexes of previous open i.START
      data = [ ]; # Modifiable data. Numbers from 0 to 255.
      output = [ ]; # Output in numbers from 0 to 255
      inherit inputs; # Leftover inputs
      isSkipping = false; # Whether it's in the process of skipping because of i.START
    }
    tokens;
in
builtins.concatStringsSep "" (
  map
    (elem: builtins.elemAt ascii elem) # Convert output to ASCII
    (
      assert builtins.length executed.sp == 0 || abort "Incorrect parenthesis: Unclosed symbol ${i.START}"; executed.output
    ) # Ensure parenthesis were closed
)
