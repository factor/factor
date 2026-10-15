! Emit the real primitive gate, including its native return-address reload.
USING: assocs bootstrap.image.private command-line compiler.constants cpu.sparc.assembler
compiler.codegen.relocation io.encodings.binary io.files kernel namespaces
parser sequences vocabs.loader ;
"compiler.constants" reload
"compiler.codegen.relocation" reload
"bootstrap.image" reload
H{ } clone special-objects set
H{ } clone sub-primitives set
command-line get first run-file
USING: kernel.private ;
JIT-PRIMITIVE special-objects get at dup first
command-line get second "primitive.reloc" append binary set-file-contents
second command-line get second "primitive.bin" append binary set-file-contents
JIT-PROLOG special-objects get at second
command-line get second "prolog.bin" append binary set-file-contents
JIT-EPILOG special-objects get at second
command-line get second "epilog.bin" append binary set-file-contents
JIT-RETURN special-objects get at second
command-line get second "return.bin" append binary set-file-contents
! Observe the native out registers before the primitive epilog rotates them.
[ 24 8 0 ORI 25 9 0 ORI ] make-jit-no-params second
command-line get second "observe.bin" append binary set-file-contents
