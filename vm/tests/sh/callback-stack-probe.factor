! Compile the actual hook, then emit its native callback argument address.
USING: arrays assocs compiler compiler.codegen.relocation compiler.errors compiler.units
cpu.architecture cpu.sh cpu.sh.assembler cpu.sh.codegen io.encodings.binary
io.files kernel make namespaces sequences system ;
M\ sh %callback-stack 1array compile
compiler-errors get assoc-empty? [ ] [ "SH callback-stack compilation failed" throw ] if
[ init-relocation 0 M\ sh %callback-stack execute( dst -- ) RETURN ] B{ } make
"callback-stack.inc.bin" binary set-file-contents
