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
  ];
in
(mkClangShell {
  name = "factor-shell-env";
  LD_LIBRARY_PATH = "/run/opengl-driver/lib:${lib.makeLibraryPath runtimeLibs}" ;
  buildInputs = runtimeLibs ++ [
    # for building factor
    git
    curl
  ];
})
