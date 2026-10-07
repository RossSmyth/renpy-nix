# renpy-nix

Packages up Ren'py game with Nix.

Does a couple useful things:
1. Compile the rpy files - reduces size
2. Use Nixpkgs-provided Ren'py so it stays up-to-date
3. Only packages essential files
4. Add .desktop file
5. Makes wrapper binary for launching

Generally Ren'py games vendor Ren'py in their distribution. This removes the vendored Ren'py so that it is deduplicated, and stays up to date. Works well, [here's some I've used it for to play](https://github.com/RossSmyth/nur/blob/13c6f0d9312b625be94225350f6a81a82dc647eb/default.nix#L59-L67).

# Usage

```nix
let
  inputs = import ./npins { };
  pkgs = import inputs.nixpkgs {
    overlays = [
      (import inputs.renpy-nix)
    ];
  };

  inherit (pkgs) buildRenpyGame fetchItchIo;
in
buildRenpyGame (finalAttrs: {
  pname = "two-kinds-of-people";
  version = "1.0";
  gameName = "Two Kinds of People";
  
  # Often the easiest thing to do is put this here, but just download it
  # in your browser and add the archive to the store with
  # `nix store add-file ./blah.zip`
  #
  # The other option is to enter this, then follow the instructions when it
  # fails since it requires an API key to run.
  src = fetchItchIo {
    name = "tkop-${finalAttrs.version}-pc.zip";
    gameUrl = "https://lacunova.itch.io/tkop";
    upload = "18254531";
    hash = "sha256-y0to2H0kXzQsOjI97IYz8sOzJBa8KQlbvN6wh6l+PtA=";
  };
})
```

Will create a `.desktop` file so the game can be launched easily.
