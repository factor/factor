! Dump production bootstrap callback/signal templates without a full image.
USING: assocs bootstrap.image.private command-line compiler.constants
compiler.codegen.relocation io.encodings.binary io.files kernel namespaces
parser sequences strings system vocabs.loader ;
"system" reload
"compiler.constants" reload
"compiler.codegen.relocation" reload
"bootstrap.image" reload
H{ } clone special-objects set
H{ } clone sub-primitives set
command-line get first "resource:basis/bootstrap/assembler/" prepend ".unix.factor" append run-file
USING: assocs bootstrap.image.private command-line io.encodings.binary
io.files kernel kernel.private namespaces sequences ;
IN: sh-integer-bootstrap-probe
: output-path ( name -- path ) command-line get second prepend ;
CALLBACK-STUB special-objects get at second "callback.bin" output-path binary set-file-contents
CALLBACK-STUB special-objects get at first "callback.reloc" output-path binary set-file-contents
USING: kernel.private ;
: dump-signal ( word name -- )
    [ sub-primitives get at third second ] [ output-path ] bi* binary set-file-contents ;
\ signal-handler "signal.bin" dump-signal
