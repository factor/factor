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
\ swap "swap.bin" dump-template
\ fixnum+fast "add.bin" dump-template
\ fixnum*fast "mul.bin" dump-template
\ fixnum/mod-fast "divmod.bin" dump-template
\ fixnum+ "checked-add.bin" dump-template
\ fixnum- "checked-sub.bin" dump-template
\ fixnum* "checked-mul.bin" dump-template
\ fpu-state "fpu-state.bin" dump-template
\ set-fpu-state "set-fpu-state.bin" dump-template
