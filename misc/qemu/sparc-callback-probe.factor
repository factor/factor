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
CALLBACK-STUB special-objects get at dup first command-line get second "callback.reloc" append binary set-file-contents
second command-line get second "callback.bin" append binary set-file-contents
\ c-to-factor "c-to-factor.bin" dump-template
\ c-to-factor sub-primitives get at third first command-line get second "c-to-factor.reloc" append binary set-file-contents
\ fpu-state "fpu-get.bin" dump-template
\ set-fpu-state "fpu-set.bin" dump-template
JIT-PROLOG special-objects get at second command-line get second "prolog.bin" append binary set-file-contents
JIT-EPILOG special-objects get at second command-line get second "epilog.bin" append binary set-file-contents
JIT-RETURN special-objects get at second command-line get second "return.bin" append binary set-file-contents
JIT-SAFEPOINT special-objects get at dup first command-line get second "safepoint.reloc" append binary set-file-contents
second command-line get second "safepoint.bin" append binary set-file-contents
USING: generic.single.private ;
: dump-combinator ( word name -- )
    [ sub-primitives get at ] dip
    2dup ".init" append [ third second ] dip command-line get second prepend binary set-file-contents
    2dup ".reloc" append [ third first ] dip command-line get second prepend binary set-file-contents
    ".tail" append [ 4 swap nth second ] dip command-line get second prepend binary set-file-contents ;
\ (call) "call" dump-combinator
\ lazy-jit-compile "lazy" dump-combinator
\ inline-cache-miss "cache" dump-combinator
\ inline-cache-miss-tail "cache-tail" dump-combinator
