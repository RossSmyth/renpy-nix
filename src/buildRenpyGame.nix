{
  lib,
  stdenvNoCC,
  renpyMinimal,
  writableTmpDirAsHomeHook,
  _7zz,
  makeBinaryWrapper,
  copyDesktopItems,
  makeDesktopItem,
}:
lib.extendMkDerivation {
  constructDrv = stdenvNoCC.mkDerivation;

  excludeDrvArgNames = [
    "gameName"
    "extraDesktopEntry"
  ];

  extendDrvArgs =
    finalAttrs:
    {
      pname,
      version,
      src,
      gameName,
      extraDesktopEntry ? { },
      meta ? { },
      nativeBuildInputs ? [ ],
    }:
    {
      strictDeps = true;
      __structuredAttrs = true;

      nativeBuildInputs = nativeBuildInputs ++ [
        _7zz
        writableTmpDirAsHomeHook
        makeBinaryWrapper
        renpyMinimal
        copyDesktopItems
      ];

      # The hook only unpack dmg files.
      unpackCmd = ''7zz x -sns- -snld "$curSrc"'';

      buildPhase = ''
        runHook preBuild

        renpy . compile
        rm -r game/saves

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        INSTALL_DIR="$out/share/${finalAttrs.pname}"

        mkdir -p -- "$INSTALL_DIR"

        cp -r -- game "$INSTALL_DIR"

        find "$INSTALL_DIR" -type f -name "*.rpy" -delete

        makeWrapper ${lib.getExe renpyMinimal} "$out/bin/${finalAttrs.pname}" \
          --add-flag "$INSTALL_DIR" \
          --add-flag run

        runHook postInstall
      '';

      desktopItems = [
        (makeDesktopItem (
          extraDesktopEntry
          // {
            name = gameName;
            desktopName = finalAttrs.pname;
            type = "Application";
            categories = [ "Game" ];
            exec = finalAttrs.pname;
          }
        ))
      ];

      meta = meta // {
        mainProgram = finalAttrs.pname;
      };
    };
}
