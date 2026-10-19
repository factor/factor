! Usage: HOST_FACTOR this-script.factor WIDTH OUTPUT_DIRECTORY_WITH_SLASH
! Dump the exact naked signal template and native-endian relocation records.
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
\ signal-handler "signal.bin" dump-template
\ signal-handler sub-primitives get at third first command-line get second "signal.reloc" append binary set-file-contents
