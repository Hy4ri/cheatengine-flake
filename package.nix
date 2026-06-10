{
  lib,
  stdenv,
  fetchurl,
  unzip,
  autoPatchelfHook,
  makeWrapper,
  # Runtime dependencies
  libX11,
  libSM,
  libICE,
  glib,
  gtk3,
  pango,
  cairo,
  gdk-pixbuf,
  atk,
  qt6,
  fontconfig,
  freetype,
  zlib,
  libGL,
  libxkbcommon,
  libxext,
  libxrender,
  libxi,
  libxcursor,
  libxfixes,
  libxrandr,
  libxcomposite,
  libxdamage,
  libxtst,
  libxcb,
  dbus,
  wayland,
  # Provided by the zip itself but we need system libstdc++
  gcc-unwrapped,
  copyDesktopItems,
  makeDesktopItem,
}:
let
  version = "7.7";
  pname = "cheatengine";

  desktopItem = makeDesktopItem {
    name = "cheatengine";
    desktopName = "Cheat Engine";
    comment = "Memory scanner and debugger for Linux";
    exec = "cheatengine";
    icon = "cheatengine";
    terminal = false;
    type = "Application";
    categories = [
      "Development"
      "Debugger"
    ];
  };

  runtimeDeps = [
    stdenv.cc.cc.lib # libstdc++
    libX11
    libSM
    libICE
    glib
    gtk3
    pango
    cairo
    gdk-pixbuf
    atk
    qt6.qtbase
    fontconfig
    freetype
    zlib
    libGL
    libxkbcommon
    libxext
    libxrender
    libxi
    libxcursor
    libxfixes
    libxrandr
    libxcomposite
    libxdamage
    libxtst
    libxcb
    dbus
    wayland
  ];

  libPath = lib.makeLibraryPath runtimeDeps;
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://cheatengine.org/download/CheatEngineLinux${lib.replaceStrings ["."] [""] version}.zip";
    hash = "sha256-Lv/pYIAVVnNyzMle0FZWT/7tfYKQI45jeBFbLiEd164=";
  };

  nativeBuildInputs = [
    unzip
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = runtimeDeps;

  sourceRoot = ".";

  unpackPhase = ''
    runHook preUnpack
    unzip $src
    runHook postUnpack
  '';

  dontBuild = true;
  dontStrip = true;
  dontWrapQtApps = true;

  installPhase = let
    dirName = "CheatEngineLinux${lib.replaceStrings ["."] [""] version}";
  in ''
    runHook preInstall

    # Install the application files
    mkdir -p "$out/opt/cheatengine"
    cp -r ${dirName}/* "$out/opt/cheatengine/"

    # Make main binary executable
    chmod +x "$out/opt/cheatengine/cheatengine-x86_64"

    # Make tutorial binary executable if it exists
    if [ -f "$out/opt/cheatengine/gtutorial-x86_64" ]; then
      chmod +x "$out/opt/cheatengine/gtutorial-x86_64"
    fi

    # Create wrapper script
    mkdir -p "$out/bin"
    makeWrapper "$out/opt/cheatengine/cheatengine-x86_64" "$out/bin/cheatengine" \
      --prefix LD_LIBRARY_PATH : "$out/opt/cheatengine" \
      --prefix LD_LIBRARY_PATH : "${libPath}" \
      --chdir "$out/opt/cheatengine"

    # Install icon
    mkdir -p "$out/share/icons/hicolor/128x128/apps"
    cp ${./cheatengine.png} "$out/share/icons/hicolor/128x128/apps/cheatengine.png"

    runHook postInstall
  '';

  desktopItems = [ desktopItem ];

  meta = {
    description = "Cheat Engine – memory scanner and debugger for Linux";
    homepage = "https://cheatengine.org";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "cheatengine";
    platforms = [ "x86_64-linux" ];
  };
}
