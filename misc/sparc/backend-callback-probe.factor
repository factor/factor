! Dump the actual bootstrap callback template, including relocation operands.
USING: assocs bootstrap.image.private command-line compiler.constants
compiler.codegen.relocation io.encodings.binary io.files io.pathnames kernel kernel.private
namespaces parser sequences vocabs.loader ;
"system" reload
"compiler.constants" reload
"compiler.codegen.relocation" reload
"bootstrap.image" reload
H{ } clone special-objects set
H{ } clone sub-primitives set
"resource:basis/bootstrap/assembler/sparc.32.factor" run-file
CALLBACK-STUB special-objects get at
[ first command-line get first "callback32.relocs" append-path binary set-file-contents ]
[ second command-line get first "callback32.bin" append-path binary set-file-contents ] bi
