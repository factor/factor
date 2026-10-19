! Copyright (C) 2026 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types arrays assocs
compiler.cfg.builder.alien.boxing compiler.cfg.builder.alien.params
compiler.cfg.hats compiler.cfg.instructions compiler.cfg.intrinsics.allot
cpu.architecture cpu.arm.32.assembler.private
cpu.arm.32.compiler-assembler kernel locals math namespaces sequences
system vectors generic ;
IN: cpu.arm.32.abi

! AAPCS-VFP allocates doubles from aligned pairs of single lanes. Keep
! skipped single lanes available: float, double, float uses s0,d1,s1.
:: prepare-double-parameter ( -- )
    float-regs get :> regs
    regs [ single?>> ] filter [ number>> even? ] filter [| reg |
        reg number>> 1 + t <vfp-register> regs member?
    ] find-last nip :> first/f
    first/f [
        first/f regs remove! drop
        first/f number>> 1 + t <vfp-register> regs remove! drop
        first/f number>> 2 /i f <vfp-register> regs push
    ] [ regs delete-all ] if ;

M: arm.32 prepare-long-long-registers
    dup last register odd? [ pop* ] [ drop ] if ;

! AAPCS requires eight-byte stack alignment when a double exhausts VFP.
M: arm.32 alloc-abi-stack-param
    over double-rep? [ stack-params [ 8 align ] change ] when
    alloc-stack-param ;

SYMBOL: vfp-group-remaining

:: prepare-vfp-group ( count double? -- )
    float-regs get :> regs
    double? 2 1 ? :> stride
    count stride * :> lanes
    16 <iota> [| start |
        start stride mod zero? start lanes + 16 <= and
        lanes <iota> [ start + t <vfp-register> regs member? ] all? and
    ] find nip :> start/f
    start/f [
        lanes <iota> [ start/f + t <vfp-register> regs remove! drop ] each
        count <iota> <reversed> [
            start/f stride /i + double? not <vfp-register> regs push
        ] each
    ] [ regs delete-all ] if
    count 1 - vfp-group-remaining set ;

:: prepare-core-parameter-group ( rep -- )
    int-regs get :> regs
    rep third regs empty? not and
    [ regs M\ arm.32 prepare-long-long-registers execute ] when
    rep length 4 > [ 4 rep nth ] [ 0 ] if :> count
    rep third regs length 2 < count regs length > or and
    [ stack-params [ 8 align ] change ] when
    ! AAPCS32 permits a composite to split across core registers and the
    ! stack only while the stack argument area is still empty (C.5/C.6).
    count 0 > stack-params get zero? and [ 0 4 rep set-nth ] when ;

M:: arm.32 prepare-abi-parameter-group ( rep -- )
    rep first reg-class-of int-regs eq? [ rep prepare-core-parameter-group ] [
        rep length 4 > [ 4 rep nth ] [ 0 ] if :> count
        count 0 > [ count rep first double-rep? prepare-vfp-group ] [
            vfp-group-remaining get 0 or 0 >
            [ -1 vfp-group-remaining +@ ]
            [ rep first double-rep? [ prepare-double-parameter ] when ] if
        ] if
    ] if ;

! OpenBSD uses the base AAPCS by default; other supported ARM32 targets
! use AAPCS-VFP. Variadic signatures always use base AAPCS for all values.
! Scope each signature so nested calls recover their own ABI.
SYMBOL: arm32-base-aapcs?
: arm32-softfp? ( -- ? ) os openbsd? ;
: base-aapcs-required? ( varargs? target-os -- ? ) openbsd? or ;
M: arm.32 prepare-abi-call
    varargs?>> >boolean os base-aapcs-required? arm32-base-aapcs? set ;
: core-floating-type? ( type -- ? )
    c-type-rep dup float-rep? swap double-rep? or ;
: base-floating-reps ( type -- reps )
    c-type-rep double-rep?
    [ { { int-rep f t 4 } { int-rep f f 4 } } ]
    [ { { int-rep f f 4 } } ] if record-reg-reps ;
M: arm.32 flatten-scalar-parameter
    arm32-base-aapcs? get over core-floating-type? and
    [ base-floating-reps ] [ call-next-method ] if ;
M: arm.32 flatten-scalar-return
    arm32-base-aapcs? get over core-floating-type? and
    [ base-floating-reps ] [ call-next-method ] if ;

:: base-unbox-floating ( src type -- vregs reps )
    src type unbox unrecord-reg-reps drop first :> value
    type c-type-rep :> rep
    rep double-rep? [
        8 8 f ^^local-allot :> buffer
        value buffer 0 double-rep f ##store-memory-imm,
        buffer 0 int-rep f ^^load-memory-imm
        buffer 4 int-rep f ^^load-memory-imm 2array
    ] [ value float-rep ^^scalar>integer 1array ] if
    type base-floating-reps ;
M: arm.32 unbox-scalar-parameter
    arm32-base-aapcs? get over core-floating-type? and
    [ base-unbox-floating ] [ call-next-method ] if ;
M: arm.32 unbox-scalar-return
    arm32-base-aapcs? get over core-floating-type? and
    [ base-unbox-floating keys ] [ call-next-method ] if ;

:: base-box-floating ( vregs reps type -- dst )
    type c-type-rep :> rep
    rep double-rep? [
        8 8 f ^^local-allot :> buffer
        vregs first buffer 0 int-rep f ##store-memory-imm,
        vregs second buffer 4 int-rep f ##store-memory-imm,
        buffer 0 double-rep f ^^load-memory-imm
    ] [ vregs first float-rep ^^integer>scalar ] if
    1array rep 1array type box ;
M: arm.32 box-scalar-parameter
    arm32-base-aapcs? get over core-floating-type? and
    [ base-box-floating ] [ call-next-method ] if ;
M: arm.32 box-scalar-return
    arm32-base-aapcs? get over core-floating-type? and
    [ base-box-floating ] [ call-next-method ] if ;
