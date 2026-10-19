! Dump actual bootstrap subprimitive code for execution by the GNU/QEMU probe.
USING: assocs bootstrap.image.private command-line compiler.constants compiler.codegen.relocation
io.encodings.binary io.files kernel namespaces parser sequences strings system
vocabs.loader ;
"compiler.constants" reload
"compiler.codegen.relocation" reload
"bootstrap.image" reload
H{ } clone special-objects set
H{ } clone sub-primitives set
command-line get first "resource:basis/bootstrap/assembler/sparc." prepend ".factor" append run-file
USING: kernel.private math.private ;
IN: sparc-bootstrap-probe
: dump-template ( word name -- )
    [ sub-primitives get at third second ]
    [ command-line get second prepend ] bi*
    binary set-file-contents ;
PIC-TAG special-objects get at second command-line get second "tag.bin" append binary set-file-contents
PIC-HIT special-objects get at dup first command-line get second "hit.reloc" append binary set-file-contents
second command-line get second "hit.bin" append binary set-file-contents
