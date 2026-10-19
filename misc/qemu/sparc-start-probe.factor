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
USING: threads.private math.parser io.encodings.utf8 ;
JIT-PROLOG special-objects get at second command-line get second "prolog.bin" append binary set-file-contents
JIT-EPILOG special-objects get at second command-line get second "epilog.bin" append binary set-file-contents
JIT-RETURN special-objects get at second command-line get second "return.bin" append binary set-file-contents
\ (start-context) "start.bin" dump-template
\ (start-context) sub-primitives get at dup third first command-line get second "start.reloc" append binary set-file-contents
second [ number>string ] map " " join command-line get second "start.here" append utf8 set-file-contents
