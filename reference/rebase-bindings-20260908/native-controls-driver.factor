USING: assocs compiler.errors compiler.units debugger io kernel namespaces sequences
 system parser tools.test vocabs.loader ;
f restartable-tests? set-global
[
    { "endian" "alien.data" "alien.libraries.finder.linux" "linux.input-events.ffi"
      "linux.input-events" "libudev" } [ dup print flush reload ] each
] with-compilation-unit
"evidence/native-controls.factor" run-file
