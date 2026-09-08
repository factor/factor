USING: namespaces parser vocabs vocabs.loader vocabs.refresh ;
<< auto-use? off "cpu.architecture" reload "alien.c-types" reload
   "alien" refresh "stack-checker" refresh "compiler" refresh "cpu" refresh
   "unix" refresh "libc" refresh "x11.syntax" reload >>
USING: accessors assocs compiler.errors debugger io io.files.temp
kernel prettyprint sequences system tools.test ;
"resource:logs/linux-bindings/tmp" current-temp-directory set-global
restartable-tests? off
auto-use? off
{ "unix.process" "unix.ffi" "unix.time" "unix.types.linux" "unix.ffi.linux" "linux.input-events.ffi" "x11.xlib" "x11.xim" "terminal.linux" } [ require ] each
{ "unix.process" "unix.ffi" "unix.time" "unix.types.linux" "unix.ffi.linux" "linux.input-events.ffi" "x11.syntax" "terminal.linux" } [ test ] each
"TEST FAILURES " write test-failures get length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
test-failures get [ error>> print-error ] each
compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
