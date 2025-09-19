{
  lib,
  stdenv,
  fetchurl,
  _7zz,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ghostty-terminfo";
  version = "1.2.0";

  src = fetchurl {
    url = "https://release.files.ghostty.org/${finalAttrs.version}/Ghostty.dmg";
    hash = "sha256-QyHKQ00iRxWS6GwPfRAi9RDSlgX/50N0+MASmnPGAo4=";
  };

  sourceRoot = ".";

  unpackPhase = ''
    runHook preUnpack
    7zz -snld x $src
    runHook postUnpack
  '';

  nativeBuildInputs = [
    _7zz
  ];

  dontBuild = true;

  outputs = [ "out" "terminfo" ];

  installPhase = ''
    runHook preInstall

    # Install terminfo to its own output
    mkdir -p $terminfo/share/terminfo
    cp -r Ghostty.app/Contents/Resources/terminfo/* $terminfo/share/terminfo/

    # Create symlink in main output for compatibility
    mkdir -p $out/share
    ln -s $terminfo/share/terminfo $out/share/terminfo

    runHook postInstall
  '';

  meta = {
    description = "Terminfo files for Ghostty terminal emulator";
    homepage = "https://ghostty.org";
    platforms = lib.platforms.all;
    outputsToInstall = [ "terminfo" ];
  };
})
