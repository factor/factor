USING: alien alien.c-types alien.libraries alien.strings alien.syntax compiler.units eval
io io.encodings.utf8 io.files kernel namespaces parser sequences splitting
system tools.test vocabs.loader words ;
IN: ffi-varargs-x11-gtk.tests
<< "xlib" "/tmp/ffi-varargs-x11-gtk.dylib" cdecl add-library >>
<< "x11.syntax" reload "x11.xlib" reload >>
USE: x11.xlib
! Parse the production declaration without loading a GUI backend on macOS.
C-TYPE: GtkWidget
C-TYPE: GtkWindow
TYPEDEF: char gchar
TYPEDEF: int gint
TYPEDEF: int GtkFileChooserAction
<< "gtk" "/tmp/ffi-varargs-x11-gtk.dylib" cdecl add-library >>
LIBRARY: gtk
<<
"resource:extra/file-picker/linux/linux.factor" utf8 file-contents
"FUNCTION: GtkWidget* gtk_file_chooser_dialog_new" split1 nip
")" split1 drop
"FUNCTION: GtkWidget* gtk_file_chooser_dialog_new" prepend ")" append
"USING: alien.syntax alien.c-types ffi-varargs-x11-gtk.tests ; IN: ffi-varargs-x11-gtk.tests LIBRARY: gtk " prepend
( -- ) eval
>>
{ XCreateIC gtk_file_chooser_dialog_new } recompile
f restartable-tests? set-global
"gtk-only" get [
{ 0x1234 } [
    f "clientWindow" 0x12345678 "focusWindow" 0x76543210
    "inputStyle" 0x100000408 "resourceName" "Factor"
    "resourceClass" "Factor" f XCreateIC alien-address
] unit-test
] unless
{ 0x5678 } [
    "Choose" utf8 string>alien f 1 "Cancel" utf8 string>alien
    -6 "Open" utf8 string>alien -3 f
    gtk_file_chooser_dialog_new alien-address
] unit-test
test-failures get empty? [ "X11/GTK ABI checks passed" print 0 ] [ 1 ] if exit
