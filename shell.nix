{
  system ? builtins.currentSystem,
  pkgs ? import <nixpkgs> { inherit system; },
  stdenv ? pkgs.stdenv,
  uiBackend ? if stdenv.hostPlatform.is32bit || builtins.elem
    stdenv.hostPlatform.parsed.cpu.name [ "s390x" "loongarch64" ]
    then "gtk3" else "gtk4",
  withUI ? true,
  withTests ? false,
}:

assert builtins.elem uiBackend [ "gtk4" "gtk3" ];

let
  inherit (pkgs) lib;
  linuxUI = withUI && stdenv.hostPlatform.isLinux;
  gtk = if uiBackend == "gtk4" then pkgs.gtk4 else pkgs.gtk3;
  libraryVariable = if stdenv.hostPlatform.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH";
  librarySuffix = "\${" + libraryVariable + ":+:$" + libraryVariable + "}";
  runtimeLibs = with pkgs; [
    openssl pcre pcre2 zlib readline libffi sqlite
    openal freealut libogg libvorbis capstone
  ] ++ lib.optionals stdenv.hostPlatform.isx86 [ pkgs.udis86 ]
    ++ lib.optionals withUI (with pkgs; [ glib pango cairo gdk-pixbuf librsvg ])
    ++ lib.optionals linuxUI (with pkgs; [
      gtk gsettings-desktop-schemas
      libepoxy libGL libGLU libX11 libXcursor libXrandr libXi
      fontconfig freetype dejavu_fonts shared-mime-info
    ]) ++ lib.optionals (linuxUI && uiBackend == "gtk3") [ pkgs.atk ]
       # The full UI prefix also exercises the legacy GTK2 bindings.
       ++ lib.optionals (linuxUI && withTests) [ pkgs.gtk2 pkgs.mesa ];
  dataPath = lib.concatStringsSep ":" (
    [ (lib.makeSearchPath "share" [ pkgs.shared-mime-info pkgs.dejavu_fonts ]) ]
    ++ map (p: "${p}/share/gsettings-schemas/${p.name}") [ gtk pkgs.gsettings-desktop-schemas ]
  );
  fontConfig = pkgs.makeFontsConf { fontDirectories = [ pkgs.dejavu_fonts ]; };
  # Discovery needs libc and libm, but adding libc to LD_LIBRARY_PATH would
  # replace the host libc in subprocesses built with a different Nixpkgs.
  libcCache = pkgs.writeText "factor-ld-so-cache" ''
    libc.so.6 (libc6) => ${stdenv.cc.libc}/lib/libc.so.6
    libm.so.6 (libc6) => ${stdenv.cc.libc}/lib/libm.so.6
  '';
  runtimeLibPath = lib.concatStringsSep ":" (
    lib.optional linuxUI "/run/opengl-driver/lib"
    ++ [ (lib.makeLibraryPath runtimeLibs) ]
  );
in
(pkgs.mkShell.override { inherit stdenv; }) {
  name = "factor-shell-env";
  nativeBuildInputs = with pkgs; [
    git curl cacert pkg-config gnumake makeWrapper file
  ] ++ lib.optionals stdenv.hostPlatform.isLinux [ pkgs.procps ]
    ++ lib.optionals (withTests && stdenv.hostPlatform.isLinux) [ pkgs.xvfb-run ];
  buildInputs = runtimeLibs ++ [ pkgs.tzdata ];
  FACTOR_UI_BACKEND = if stdenv.hostPlatform.isDarwin then "cocoa" else uiBackend;
  TZDIR = "${pkgs.tzdata}/share/zoneinfo";

  shellHook = ''
    export ${libraryVariable}=${lib.escapeShellArg runtimeLibPath}${librarySuffix}
  '' + lib.optionalString stdenv.hostPlatform.isLinux ''
    export FACTOR_LD_SO_CACHE="${libcCache}"
  '' + lib.optionalString linuxUI ''
    # The setup hook selects the largest cache, including the SVG loader.
    unset GDK_PIXBUF_MODULE_FILE
    findGdkPixbufLoaders "${pkgs.librsvg}"
    export XDG_DATA_DIRS="${dataPath}:''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
    export FONTCONFIG_FILE="${fontConfig}"
  '' + lib.optionalString (linuxUI && withTests) ''
    # Supply stock Mesa software rendering for Xvfb and minimal QEMU guests.
    export LIBGL_DRIVERS_PATH="${pkgs.mesa}/lib/dri"
    export __EGL_VENDOR_LIBRARY_FILENAMES="${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json"
  '' + ''
    # Opt in after building. Rebuilding replaces the wrapper with a new VM;
    # calling this again installs that VM, without accumulating wrappers.
    wrapLocalFactor() {
      if [ "$#" -ne 1 ]; then
        printf 'Usage: wrapLocalFactor <factor-root>\n' >&2
        return 1
      fi
      local root binary wrapped flags
      root=$(cd -- "$1" && pwd -P) || return
      binary="$root/factor"
      wrapped="$root/.factor-wrapped"
      if ${pkgs.file}/bin/file -Lb "$binary" | grep -Eq 'ELF|Mach-O'; then
        mv -f -- "$binary" "$wrapped" || return
      elif ! [ -x "$wrapped" ] || ! grep -qF '# Factor development wrapper' "$binary"; then
        printf 'Expected a compiled Factor VM at %s\n' "$binary" >&2
        return 1
      fi
      # Keep the public image name even though /proc/self/exe sees the hidden
      # VM. Quoting also permits checkout paths containing spaces.
      printf -v flags '%q ' "-i=$root/factor.image" "-resource-path=$root"
      makeWrapper "$wrapped" "$binary" \
        --run '# Factor development wrapper' \
        --add-flags "$flags" \
        --prefix ${libraryVariable} : ${lib.escapeShellArg runtimeLibPath} \
        --set-default TZDIR "$TZDIR" \
        ${lib.optionalString stdenv.hostPlatform.isLinux ''--set FACTOR_LD_SO_CACHE "${libcCache}" \''}
        ${lib.optionalString linuxUI ''--set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE" \
        --set FONTCONFIG_FILE "$FONTCONFIG_FILE" \
        --prefix XDG_DATA_DIRS : "$XDG_DATA_DIRS" \''}
        --argv0 factor || return
    }
  '';
}
