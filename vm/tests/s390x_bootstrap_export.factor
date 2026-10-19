! Export the actual generated bootstrap subprimitives for native probes.
! Run with the host Factor VM and resource-path set to this checkout.
USING: accessors arrays assocs bootstrap.image bootstrap.image.private byte-arrays
compiler.constants io io.encodings.binary io.files kernel kernel.private namespaces parser
sequences sequences.generalizations splitting strings vocabs.loader words ;
"system" reload
"cpu.architecture" reload
"alien.c-types" reload
"compiler.cfg.builder.alien.params" reload
"compiler.cfg.builder.alien.boxing" reload
"compiler.constants" reload
"compiler.codegen.relocation" reload
"bootstrap.image" reload
"s390x.linux" architecture set
H{ } clone special-objects set
"resource:basis/bootstrap/stage1.factor" run-file
sub-primitives get [
    swap name>> "/" "_" replace "s390x-" prepend ".bin" append
    [ third second ] dip binary set-file-contents
] assoc-each
60 special-objects get at
[ first "s390x-MEGA-relocations.bin" binary set-file-contents ]
[ second "s390x-MEGA.bin" binary set-file-contents ] bi
81 special-objects get at second "s390x-PIC-MISS.bin" binary set-file-contents
CALLBACK-STUB special-objects get at [
    [ first "s390x-CALLBACK-relocations.bin" binary set-file-contents ]
    [ second "s390x-CALLBACK.bin" binary set-file-contents ] bi
] [
    third
    [ first "s390x-VARARGS-CALLBACK-relocations.bin" binary set-file-contents ]
    [ second "s390x-VARARGS-CALLBACK.bin" binary set-file-contents ] bi
] bi
vm-context-offset vm-spare-context-offset
context-callstack-save-offset context-callstack-bottom-offset
context-datastack-offset context-retainstack-offset
6 narray >byte-array "s390x-CALLBACK-offsets.bin" binary set-file-contents
context-callstack-top-offset alien-offset 2array >byte-array
"s390x-CONTEXT-offsets.bin" binary set-file-contents
