{ pkgs ? import <nixpkgs> {} }:
(pkgs.buildFHSUserEnv {
  name = "factor";
  targetPkgs = pkgs: (with pkgs; [
    # for running factor
    gtk2-x11
    glib
    gdk_pixbuf
    gnome2.pango
    cairo
    gnome2.gtkglext

    # for building factor
    clang
    git
    curl
    binutils
  ]);
  runScript = "bash";
}).env
