{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
  mkClangShell = mkShell.override { stdenv = clangStdenv; };
  runtimeLibs = with xorg; [
    glib
    pango cairo
    pcre
    libGL
    libGLU
    freealut
    openssl
    udis86 # available since NixOS 19.09
    openal
    libogg
    libvorbis
    zlib
  ] ++ (if stdenv.isDarwin then [] else [
    gtk2-x11
    gdk_pixbuf
    gnome2.gtkglext
  ]);
  runtimeLibPath = "/run/opengl-driver/lib:" + lib.makeLibraryPath runtimeLibs;
in
(mkClangShell {
  name = "factor-shell-env";
  LD_LIBRARY_PATH = runtimeLibPath ;
  buildInputs = runtimeLibs ++ [
    # for building factor
    git
    curl
    makeWrapper
  ] ++ (if stdenv.isDarwin then [darwin.apple_sdk.frameworks.Cocoa] else []);
  shellHook = ''
    # Set Gdk pixbuf loaders file to the one from the build dependencies here
    unset GDK_PIXBUF_MODULE_FILE
    # Defined in gdk-pixbuf setup hook
    findGdkPixbufLoaders "${pkgs.librsvg}"

    wrapFactor () {
    [ -n "$1" ] || { printf "Usage: wrapFactor <factor-root>" ; return; }
    local root="$(realpath $1)"
    local binary="''${root}/factor"
    local wrapped="''${root}/.factor-wrapped"
    # Remove the wrapped binary if a new VM has been compiled
    ${lib.getBin file}/bin/file "$binary" |grep ELF >/dev/null && rm -f "$wrapped"
    # Restore the factor binary if it was already wrapped
    [ -e "$wrapped" ] && { mv "$wrapped" "$binary" ; }
    wrapProgram "$binary" --prefix LD_LIBRARY_PATH : ${runtimeLibPath} \
      --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE" \
      --argv0 factor
    ln -sf "''${root}/factor.image" "''${root}/.factor-wrapped.image"
    }
  '';
})
