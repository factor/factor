USING: assocs compiler.errors compiler.units debugger io kernel namespaces sequences
 system tools.test vocabs.loader ;
f restartable-tests? set-global
[
    { "endian" "alien.data" "alien.libraries.finder.linux" "linux.input-events.ffi"
      "linux.input-events" "libudev" } [ dup print flush reload ] each
] with-compilation-unit
{ "alien.libraries.finder.linux" "linux.input-events" "libudev" } [ test ] each
test-failures get empty? compiler-errors get assoc-empty? and
[ "Linux integration tests passed" print 0 ]
[ :test-failures compiler-errors get values [ print-error ] each 1 ] if flush exit
