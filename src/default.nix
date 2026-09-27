{
  lib,
  newScope,
}:
lib.makeScope newScope (self: {
  buildRenpyGame = self.callPackage ./buildRenpyGame.nix { };
})
