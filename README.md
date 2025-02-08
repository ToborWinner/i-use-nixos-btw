# "I use NixOS btw" programming language interpreted in Nix

This is Turing-complete programming language interpreted in Nix (coded in Nix) based on [Brainfuck](https://en.wikipedia.org/wiki/Brainfuck) and inspired by [i-use-arch-btw](https://github.com/overmighty/i-use-arch-btw)

The keywords used in this language are the following: `i`, `use`, `nix`, `and`, `nixos`, `by`, `the`, `way`.

## Quick Start

**Note:** You must have Nix installed on your system for this to work.

1. Clone this repository
```bash
git clone https://github.com/ToborWinner/i-use-nixos-btw"
```
2. Write your `I use NixOS btw` program in a file, such as `helloworld.iusenixosbtw`.
3. Run the following command to evaluate your program:
```bash
nix eval --impure --raw --option max-call-depth 100000 --expr 'import ./. { code = (builtins.readFile ./helloworld.iusenixosbtw); }'
```

## Example
This is an example `Hello World!` program written in i-use-nixos-btw:
```
nix nix nix nix nix nix nix nix the i nix nix nix nix the i nix nix i nix nix nix i nix nix nix i nix use use use use and way i nix i nix i and i i nix the use way use and way i i nixos i and and and nixos nix nix nix nix nix nix nix nixos nixos nix nix nix nixos i i nixos use and nixos use nixos nix nix nix nixos and and and and and and nixos and and and and and and and and nixos i i nix nixos i nix nix nixos
```

## Language Specification

Just like in Brainfuck, you have a limited memory (limit is 2^16^ = 65536 by default, but can be changed. See [Custom Settings](#custom-settings)).

Inputs have to be specified before running the program to the nix command. The format is a list of numbers (0-255) representing the ASCII characters.

The following would be the equivalent of typing the character `2` and pressing `Enter`:
```bash
nix eval --impure --raw --option max-call-depth 100000 --expr 'import ./. { code = (builtins.readFile ./helloworld.iusenixosbtw); inputs = [ 50 10 ]; }'
```

You can use the following instructions to operate on this memory:
| Instruction | Description |
|---------|-------------|
| `i` | Move the data pointer to the right (next cell) |
| `use` | Move the data pointer to the left (previous cell) |
| `nix` | Increment the value at the current cell by 1 |
| `and` | Decrement the value at the current cell by 1 |
| `nixos` | Output the ASCII character corresponding to the value at the current cell |
| `by` | Input a character and store its ASCII value in the current cell |
| `the` | Jump past the matching `way` if the value at the current cell is 0 |
| `way` | Jump back to the matching `the` if the value at the current cell is not 0 |

## Custom Settings

`code` and `inputs` are not the only settings that can be passed to the default.nix function.
A full list can be found here:

| Setting | Description | Required | Default |
|---------|-------------|--|--|
| `code` | The code to execute | ✅ | - |
| `inputs` | The inputs to pass to the code | ❌ | [ ] |
| `limit` | Whether to limit the memory length | ❌ | true |
| `limitNum` | The index of the last element of the memory | ❌ | 65535 |
| `abortOnDataPointerLimit` | Whether to abort when trying to go out of memory bounds | ❌ | false |
| `brainfuck` | Whether to parse the input code as Brainfuck rather than `I use NixOS btw` | ❌ | false |

## Converting from Brainfuck

If you have a Brainfuck program you would like to convert to `I use NixOS btw`, you can follow those instructions:

1. Clone this repository
```bash
git clone https://github.com/ToborWinner/i-use-nixos-btw"
```
2. Write your Brainfuck program in a file, such as `helloworld.b`.
3. Run the following command to convert your program and place the output in `helloworld.iusenixosbtw`:
```bash
nix eval --impure --raw --expr 'import ./bf-to-nixos.nix (builtins.readFile ./helloworld.b)' > helloworld.iusenixosbtw
```

## License
This software is licensed under the [MIT License](https://github.com/ToborWinner/i-use-nixos-btw/blob/master/LICENSE).
