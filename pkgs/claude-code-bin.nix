{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
}: let
  version = "1.0.119";

  selectSystem = system:
    {
      "x86_64-linux" = {
        suffix = "linux-x64";
        hash = "sha256-NDb7Nfk/yYF9Fl4IhlFHP4nDWYrtdMWP2ahLiMvq5cE=";
      };
      "aarch64-linux" = {
        suffix = "linux-arm64";
        hash = "sha256-fGUVTua5DS0ecfxzgEPsd01JczA6KF66bp23xIbsEZs=";
      };
      "x86_64-darwin" = {
        suffix = "darwin-x64";
        hash = "sha256-kHOExt1nAaXUZJebElIzx4GCbumOIyqKpHGr5yQO/EA=";
      };
      "aarch64-darwin" = {
        suffix = "darwin-arm64";
        hash = "sha256-4x/jVOBTk0cHrgSrgmHpCElqQbL0WT4h978ThOQWqwE=";
      };
    }.${
      system
    } or (throw "Unsupported system: ${system}");

  systemInfo = selectSystem stdenv.hostPlatform.system;
  suffix = systemInfo.suffix;
  hash = systemInfo.hash;
in
  stdenv.mkDerivation {
    pname = "claude-code-bin";
    inherit version;

    src = fetchurl {
      url = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${version}/${suffix}/claude";
      inherit hash;
      executable = true;
    };

    nativeBuildInputs =
      [makeWrapper]
      ++ lib.optionals stdenv.isLinux [autoPatchelfHook];

    dontStrip = true;
    dontUnpack = true;

    installPhase = ''
      runHook preInstall

      install -Dm755 $src $out/bin/claude

      runHook postInstall
    '';

    postInstall = ''
      wrapProgram $out/bin/claude \
      --set DISABLE_AUTOUPDATER 1 \
      --unset DEV
    '';

    # Claude tries to create directories when running --version
    # so we skip the install check
    doInstallCheck = false;

    meta = with lib; {
      description = "Claude Code - AI-powered coding assistant CLI";
      homepage = "https://claude.com/product/claude-code";
      changelog = "https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md";
      sourceProvenance = with sourceTypes; [binaryNativeCode];
      license = licenses.unfree;
      maintainers = [];
      platforms = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
      mainProgram = "claude";
    };
  }
