USING: accessors arrays compiler.cfg
compiler.cfg.build-stack-frame compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.stack-frame
compiler.cfg.utilities compiler.codegen compiler.codegen.gc-maps
compiler.codegen.relocation compiler.test cpu.architecture
cpu.x86 cpu.x86.assembler cpu.x86.assembler.operands
cpu.x86.features kernel kernel.private layouts literals make
math math.libm namespaces sequences slots.syntax system
tools.test ;
IN: cpu.x86.tests

{ } [
    [ { float } declare fsqrt ]
    [ ##sqrt? ] contains-insn?
    sse2?
    assert=
] unit-test

! (%compare-tagged)
cpu x86.64? [
    {
        B{ 72 129 248 255 255 255 255 }
    } [
        init-relocation [ RAX RAX (%compare-tagged) ] B{ } make
    ] unit-test
] when

! %add-imm
{
    B{ 72 255 192 }
    B{ 72 131 192 29 }
} [
    [ RAX RAX 1 %add-imm ] B{ } make
    [ RAX RAX 29 %add-imm ] B{ } make
] unit-test

! %and-imm
{
    B{ 131 225 6 }
} [
    [ RCX RCX 0x6 %and-imm ] B{ } make
] unit-test

! %alien-invoke
{ 1 } [
    [
        f { } { } { } { } 0 0 { } "dll"
        T{ gc-map { gc-roots V{ T{ spill-slot { n 0 } } } } }
        %alien-invoke
    ] with-fixup drop gc-maps get length
] unit-test

! %call-gc
{ V{ } } [
    [
        T{ gc-map } %call-gc
    ] with-fixup drop gc-maps get
] unit-test

{ 1 } [
    [
        T{ gc-map { gc-roots V{ T{ spill-slot { n 0 } } } } } %call-gc
    ] with-fixup drop gc-maps get length
] unit-test

! %clear
{ t } [
    [ D: 0 %clear ] B{ } make
    cpu x86.32? B{ 199 6 144 18 0 0 } B{ 73 199 6 144 18 0 0 } ? =
] unit-test

! %dispatch
cpu x86.64? [
    {
        B{ 72 187 0 0 0 0 0 0 0 0 72 255 100 3 6 0 }
    }
    [
        init-relocation [ RAX RBX %dispatch ] B{ } make
    ] unit-test
] when

! %load-immediate
{ B{ 49 201 } } [
    [ RCX 0 %load-immediate ] B{ } make
] unit-test

! %prepare-varargs
${
    ! xor eax, eax
    cpu x86.64? os unix? and B{ 49 192 } B{ } ?
    ! mov al, 2
    cpu x86.64? os unix? and B{ 176 2 } B{ } ?
} [
    [ { } %prepare-var-args ] B{ } make
    [
        {
            { T{ spill-slot } int-rep RDI }
            { T{ spill-slot { n 0 } } float-rep XMM0 }
            { T{ spill-slot { n 8 } } double-rep XMM1 }
        } %prepare-var-args
    ] B{ } make
] unit-test

! %prologue
{ t } [
    [ 2 cells %prologue ] B{ } make
    [ pic-tail-reg PUSH ] B{ } make =
] unit-test

{ t } [
    [ 8 cells %prologue ] B{ } make
    [ stack-reg 7 cells SUB ] B{ } make =
] unit-test

!  %replace-imm
cpu x86.64? [
    {
        B{ 73 199 6 0 0 0 0 }
    }
    [
        init-relocation [ 34.0 D: 0 %replace-imm ] B{ } make
    ] unit-test
] when

: cfg-w-spill-area-base ( base -- cfg )
    stack-frame new swap >>spill-area-base
    { } insns>cfg swap >>stack-frame ;

: expected-gc-root-offset ( slot-number spill-area-base -- offset )
    [ spill-slot boa ] [ cfg-w-spill-area-base ] bi*
    cfg [
        gc-root-offset reserved-stack-space cell / -
    ] with-variable ;

cpu x86.64? [
    ! The offset is 1, not 0 because the return address occupies the
    ! first position in the stack frame.
    { 1 } [ 0 0 expected-gc-root-offset ] unit-test

    { 10 } [ 8 64 expected-gc-root-offset ] unit-test

    { 20 } [ 24 128 expected-gc-root-offset ] unit-test
] when

{
    ! 91 8 align
    96
    ! 91 8 align 16 +
    112
    ! 91 8 align 16 + 16 8 align + cell + 16 align
    144
} [
    T{ stack-frame
        { params 91 }
        { allot-area-align 8 }
        { allot-area-size 10 }
        { spill-area-align 8 }
        { spill-area-size 16 }
    } finalize-stack-frame
    slots[ allot-area-base spill-area-base total-size ]
    ! Exclude any reserved stack space 32 bytes on win64, 0 bytes
    ! on all other platforms.
    reserved-stack-space -
] unit-test

SINGLETON: fake-cpu

fake-cpu \ cpu set

M: fake-cpu gc-root-offset ;

! Fix the gc root offset calculations
SINGLETON: linux-x86.64
M: linux-x86.64 reserved-stack-space 0 ;
M: linux-x86.64 gc-root-offset
    n>> spill-offset cell + cell /i ;

: array>spill-slots ( seq -- spills )
    [ spill-slot boa ] map ;

: <gc-map/spills> ( spills -- gc-map )
    array>spill-slots { } gc-map boa ;

cpu x86.64? [
    linux-x86.64 \ cpu set

    ! gc-root-offsets
    { { 1 3 } } [
        0 cfg-w-spill-area-base cfg [
            { 0 16 } <gc-map/spills> gc-root-offsets
        ] with-variable
    ] unit-test

    { { 6 10 } } [
        32 cfg-w-spill-area-base cfg [
            { 8 40 } <gc-map/spills> gc-root-offsets
        ] with-variable
    ] unit-test

    { 5 B{ 18 } } [
        0 cfg-w-spill-area-base cfg [
            { 0 24 } <gc-map/spills> 1array
            [ emit-gc-info-bitmap ] B{ } make
        ] with-variable
    ] unit-test

    { 9 B{ 32 1 } } [
        32 cfg-w-spill-area-base cfg [
            { 0 24 } <gc-map/spills> 1array
            [ emit-gc-info-bitmap ] B{ } make
        ] with-variable
    ] unit-test

    fake-cpu \ cpu set
] when
