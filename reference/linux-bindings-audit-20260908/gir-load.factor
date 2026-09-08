USING: namespaces parser vocabs vocabs.loader vocabs.refresh ;
<< auto-use? off "cpu.architecture" reload "alien.c-types" reload
   "alien" refresh "stack-checker" refresh "compiler" refresh "cpu" refresh
   "unix" refresh "libc" refresh "x11.syntax" reload >>
USING: accessors assocs compiler.errors debugger io kernel
prettyprint sequences system tools.test words ;
auto-use? off
{ "glib.ffi" "gobject.ffi" "gio.ffi" "gtk2.ffi" "file-picker.linux" }
[ dup print flush require ] each
"gtk_file_chooser_dialog_new" "file-picker.linux.private" lookup-word
def>> 4 swap nth 4 assert=
"COMPILER ERRORS " write compiler-errors get assoc-size .
compiler-errors get values [ print-error ] each
compiler-errors get assoc-empty? 0 1 ? exit
