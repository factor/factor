! Generate caller code with a live spill and both entry-poll topologies.
USING: accessors byte-arrays command-line compiler.cfg compiler.cfg.builder
compiler.cfg.builder.blocks compiler.cfg.instructions compiler.cfg.stacks
compiler.codegen compiler.codegen.gc-maps compiler.codegen.relocation compiler.constants
cpu.architecture cpu.sparc cpu.sparc.assembler endian io.encodings.ascii
io.encodings.binary io.files kernel layouts make math math.parser namespaces
sequences strings system tools.test ;
IN: sparc-entry-gc
: entry-insns ( -- insns )
    [ begin-stack-analysis <basic-block> dup set-basic-block
      dup begin-word drop instructions>> ] with-scope ;
: save-first? ( -- ? )
    entry-insns [ first ##prologue? ] [ second ##safepoint? ] bi and ;
{ f } [ f \ cpu set save-first? ] unit-test
{ f } [ ppc.32 \ cpu set save-first? ] unit-test
{ f } [ ppc.64 \ cpu set save-first? ] unit-test
{ f } [ hppa.32 \ cpu set save-first? ] unit-test
{ f } [ m88k.32 \ cpu set save-first? ] unit-test
{ t } [ sparc.32 \ cpu set save-first? ] unit-test
{ t } [ sparc.64 \ cpu set save-first? ] unit-test
: frame-size ( -- n ) reserved-area 16 + ;
: emit-caller ( -- offset bytes )
    init-relocation [
        frame-size %prologue
        24 sp-reg reserved-area stack-bias + %cell-store
        \ dup %call compiled-offset
        24 sp-reg reserved-area stack-bias + %cell-load
        frame-size %epilogue %return
    ] B{ } make ;
: emit-callee ( after? -- bytes )
    init-relocation [
        [ reserved-area %prologue %safepoint ]
        [ %safepoint reserved-area %prologue ] if
        reserved-area %epilogue %return
    ] B{ } make ;
: emit-current ( -- bytes )
    init-relocation [
        V{ } clone return-addresses set V{ } clone gc-maps set
        entry-insns 2 head [
            dup ##prologue? [ drop reserved-area %prologue ] [ generate-insn ] if
        ] each
        reserved-area %epilogue %return
    ] B{ } make ;
: write-code ( bytes stem -- )
    [ ".bin" append binary set-file-contents ] keep
    relocation-table get >byte-array swap ".reloc" append binary set-file-contents ;
: emit-width ( target width stem -- )
    [ \ cell set \ cpu set big-endian relocation-byte-order set
      emit-caller
    ] dip
    [ "/caller" append write-code ] keep
    [ [ number>string ] dip "/caller.offset" append ascii set-file-contents ] keep
    [ f emit-callee swap "/before" append write-code ] keep
    [ t emit-callee swap "/after" append write-code ] keep
    emit-current swap "/current" append write-code ;
sparc.32 4 command-line get first "/32" append emit-width
sparc.64 8 command-line get first "/64" append emit-width
