! Native-test the actual hard-SH4 argument allocator and emitted shuffle.
USING: accessors alien.c-types arrays classes.struct compiler.cfg
compiler.cfg.builder.alien compiler.cfg.builder.alien.boxing compiler.cfg.builder.alien.params
compiler.cfg.instructions compiler.cfg.registers compiler.cfg.stack-frame
compiler.codegen.relocation cpu.architecture cpu.sh cpu.sh.abi cpu.sh.assembler cpu.sh.codegen
io.encodings.binary io.files kernel locals make math namespaces sequences system ;
IN: sh.argument.boundary.probe
STRUCT: boundary-pair { low uint } { high uint } ;
sh4.32 \ cpu set
T{ cfg { stack-frame T{ stack-frame { spill-area-base 32 } } } } cfg set
: begin-probe ( -- )
    SP SP -128 add-offset FP SP 120 SW temp STS-PR temp SP 124 SW
    4 SP 48 SW CTX 5 MV
    temp 1 LI temp SP 52 SW temp 2 LI temp SP 56 SW
    temp 3 LI temp SP 60 SW
    temp 19088743 LI temp SP 64 SW
    temp 2309737967 LI temp SP 68 SW ;
: end-probe ( -- )
    7 SP 124 LW 7 LDS-PR FP SP 120 LW SP SP 64 add-offset SP SP 64 add-offset RETURN ;
! This emitter runs in the 64-bit host VM. Model the measured 4-byte SH
! argument slots explicitly, while retaining each production grouping flag.
:: word-reps ( reps -- reps' )
    reps [| rep |
        rep first3 4 4array
        rep length 4 > [ 4 rep nth suffix ] when
    ] map ;
! Host ulonglong is one 64-bit cell; use the production 32-bit word-pair
! classification and its dynamic SH ABI flags instead.
: wide-word-reps ( -- reps )
    int-rep long-long-on-stack?
    long-long-odd-register? long-long-even-register? or 3array
    int-rep long-long-on-stack? f 3array 2array ;
:: emit-probe ( type -- bytes relocs )
    f [
        t compact-stack-params? set
        { 20 24 28 32 36 } [ <spill-slot> ] map
        { int int int } [ lookup-c-type flatten-c-type ] map concat
        type ulonglong eq? [ wide-word-reps ] [ type lookup-c-type flatten-c-type ] if
        append word-reps (caller-parameters)
    ] with-param-regs :> ( regs stack )
    init-relocation [ begin-probe
        f regs stack { } { } 0 32 [ 16 <spill-slot> 32 f cpu.sh:c-indirect ]
        M\ sh %alien-assembly execute( varargs? reg-inputs stack-inputs reg-outputs dead-outputs
            cleanup stack-size quot -- )
        end-probe ] B{ } make relocation-table get ;
ulonglong emit-probe "wide.reloc" binary set-file-contents "wide.bin" binary set-file-contents
boundary-pair emit-probe "record.reloc" binary set-file-contents "record.bin" binary set-file-contents
