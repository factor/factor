USING: namespaces parser vocabs vocabs.loader vocabs.refresh ;
<< auto-use? off "cpu.architecture" reload "alien.c-types" reload
   "alien" refresh "stack-checker" refresh "compiler" refresh "cpu" refresh
   "unix" refresh "libc" refresh "x11.syntax" reload >>
USING: accessors alien.libraries assocs compiler.errors debugger io
io.files.temp kernel prettyprint sequences system tools.test ;
"resource:logs/linux-bindings/tmp" current-temp-directory set-global
restartable-tests? off
auto-use? off
{
    "io.monitors.linux" "io.files.info.unix.linux" "system-info.linux"
    "unix.utmpx" "unix.linux.proc" "io.launcher.unix"
    "libudev" "x11.xinput2.ffi"
} [ require ] each
{ t } [ "librt" library-dll dll-valid? ] unit-test
{ t } [ "libudev" library-dll dll-valid? ] unit-test
{ t } [ "xinput2" library-dll dll-valid? ] unit-test
{
    "io.monitors.linux" "io.files.info.unix.linux" "system-info.linux"
    "unix.utmpx" "unix.linux.proc" "io.launcher.unix"
} [ test ] each
"TEST FAILURES " write test-failures get length .
"COMPILER ERRORS " write compiler-errors get assoc-size .
test-failures get [ error>> print-error ] each
compiler-errors get values [ print-error ] each
test-failures get empty? compiler-errors get assoc-empty? and 0 1 ? exit
