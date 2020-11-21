{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
  mkClangShell = mkShell.override { stdenv = clangStdenv; };
  runtimeLibs = with xorg; [
    glib
    pango cairo
    gtk2-x11
    gdk_pixbuf
    gnome2.gtkglext
    pcre
    mesa_glu
    freealut
    openssl
    udis86 # available since NixOS 19.09
    openal
    libogg
    libvorbis
    zlib
  ];
  runtimeLibPath = lib.makeLibraryPath runtimeLibs;
in
(mkClangShell {
  name = "factor-shell-env";
  LD_LIBRARY_PATH = "/run/opengl-driver/lib:${runtimeLibPath}" ;
  buildInputs = runtimeLibs ++ [
    # for building factor
    git
    curl
    makeWrapper
  ];
  shellHook = ''
    wrapFactor () {
    [ -n "$1" ] || { printf "Usage: wrapFactor <factor-root>" ; return; }
    local root="$(realpath $1)"
    local binary="''${root}/factor"
    wrapProgram "$binary" --prefix LD_LIBRARY_PATH : ${runtimeLibPath} \
      --argv0 factor
    ln -sf "''${root}/factor.image" "''${root}/.factor-wrapped.image"
    }
  '';
})
