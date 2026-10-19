! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.c-types.capabilities alien.libraries alien.strings arrays
assocs classes.struct combinators compiler.cfg compiler.cfg.builder
compiler.cfg.builder.alien.boxing compiler.cfg.builder.alien.params
compiler.cfg.hats compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.stacks compiler.cfg.stacks.local compiler.errors
compiler.tree cpu.architecture kernel layouts locals make math math.order namespaces
sequences sequences.generalizations stack-checker.alien system
words ;
IN: compiler.cfg.builder.alien

: check-floating-point-signature ( params -- )
    dup [ parameters>> ] [ return>> ] bi prefix check-floating-point-types ;

: with-param-regs ( abi quot -- reg-values stack-values )
    '[
        param-regs init-regs
        0 stack-params set
        0 stack-group-remaining set
        V{ } clone reg-values set
        V{ } clone stack-values set
        0 int-reg-reps set
        0 float-reg-reps set
        os macos? cpu arm.64? and compact-stack-params? set
        @
        reg-values get
        stack-values get
        stack-params get
        struct-return-area get
    ] with-scope
    struct-return-area set
    stack-params set ; inline

SYMBOL: varargs-named-count

:: mark-vararg-group ( reps alignment -- reps' )
    reps [| rep i |
        rep first3 rep param-natural-size 4array
        rep length 4 > [ 4 rep nth ] [ 0 ] if suffix
        i 0 = suffix i reps length 1 - = suffix
        alignment suffix
    ] map-index ;

:: mark-varargs ( groups parameters -- groups' )
    varargs-named-count get :> named
    named integer? [
        groups [| reps i |
            i named >= [ reps i parameters nth base-type
                t varargs-parameter? [
                    dup struct-c-type? [ frob-struct ] when
                    c-type-align
                ] with-variable mark-vararg-group ] [ reps ] if
        ] map-index
    ] [ groups ] if ;

! Windows passes every argument of a variadic signature through the GP
! bank. Preserve floating-point payloads instead of converting numerically.
:: windows-vararg-payload ( vreg rep -- vregs reps )
    rep first :> representation
    representation vector-rep? [
        16 16 f ^^local-allot :> buffer
        vreg buffer 0 representation f ##store-memory-imm,
        buffer 0 int-rep f ^^load-memory-imm
        buffer 8 int-rep f ^^load-memory-imm 2array
        { { int-rep f f 8 } { int-rep f f 8 } }
    ] [
        representation reg-class-of float-regs eq? [
            vreg representation ^^scalar>integer
            int-rep f f rep param-natural-size 4array
        ] [ vreg rep ] if [ 1array ] bi@
    ] if ;

: windows-vararg-parameters ( vregs reps -- vregs' reps' )
    [ windows-vararg-payload ] 2 2 mnmap [ concat ] bi@ ;

:: unbox-parameters ( parameters -- vregs reps )
    parameters length <iota> <reversed> parameters
    [| index type |
        varargs-named-count get :> named
        named integer?
        [ parameters length 1 - index - named >= ] [ f ] if
        varargs-parameter? [
            index <ds-loc> peek-loc type base-type unbox-parameter
            int-reg-reps get float-reg-reps get
        ] with-variable
        ! Keep register-bank counts across the per-parameter scope.
        float-reg-reps set int-reg-reps set
    ]
    2 2 mnmap parameters mark-varargs [ concat ] bi@
    windows-arm64-varargs? get [ windows-vararg-parameters ] when
    parameters length neg <ds-loc> inc-stack ;

:: prepare-struct-caller ( vregs reps return -- vregs' reps' return-vreg/f )
    return large-struct? [
        return [ heap-size ] [ c-type-align cell max ] bi f ^^local-allot :> result
        struct-return-stack-offset [
            result int-rep rot cell 4array stack-values get push
            vregs reps
        ] [
            struct-return-register [
                result int-rep rot 3array reg-values get push
                vregs reps
            ] [
                vregs result prefix
                reps int-rep struct-return-on-stack? f 3array prefix
            ] if*
        ] if* result
    ] [ vregs reps f ] if ;

: handle-varargs-named-count ( params -- )
    varargs?>> os macos? cpu arm.64? and cpu riscv? cpu loongarch.64? or or
    cpu mips? or cpu hppa? or cpu openrisc.32? or [ drop f ] unless
    varargs-named-count set ;

: start-vararg ( alignment -- )
    cpu mips? cpu hppa? or [ drop ] [ cpu riscv? cpu loongarch.64? or [
        ! Double-XLEN variadic values start at an even argument register.
        dup cell 2 * >= int-regs get empty? not and [
            int-regs get length odd? [ int-regs get pop* ] when
        ] when
        int-regs get empty? [ cell max '[ _ align ] stack-params swap change ] [ drop ] if
    ] [
        ! Apple uses eight-byte slots; OpenRISC uses four-byte slots.
        ! Over-aligned aggregates retain their C alignment.
        int-regs get delete-all float-regs get delete-all
        cpu openrisc.32? [ cell max ] [ 8 max ] if
        '[ _ align ] stack-params swap change
    ] if ] if ;

:: caller-parameter ( vreg rep -- )
    rep length 8 = [ 5 rep nth [ 7 rep nth start-vararg ] when ] when
    rep prepare-parameter-group
    vreg rep first3 rep param-natural-size next-parameter
    cpu riscv? cpu loongarch.64? or rep length 8 = and [
        stack-params get 0 > [ int-regs get delete-all ] when
    ] when
    rep length 8 = [ 6 rep nth [ stack-params [ cell align ] change ] when ] when ;

: (caller-parameters) ( vregs reps -- )
    [ caller-parameter ] 2each ;

: windows-arm64-varargs-call? ( params -- ? )
    varargs?>> >boolean os windows? cpu arm.64? and and ;

: caller-parameters ( params -- reg-inputs stack-inputs )
    {
        [ abi>> ]
        [ ]
        [ return>> large-struct? ]
        [ windows-arm64-varargs-call? ]
        [ parameters>> ]
        [ return>> ]
    } cleave
    '[
        _ dup prepare-abi-call handle-varargs-named-count
        _ cpu riscv? cpu loongarch.64? or cpu mips? or and [ 1 int-reg-reps set ] when
        _ windows-arm64-varargs? [ _ unbox-parameters ] with-variable
        _ prepare-struct-caller struct-return-area set
        (caller-parameters)
    ] with-param-regs ;

: prepare-caller-return ( params -- reg-outputs )
    dup '[ _ return>> [ { } ] [ base-type load-return ] if-void ] with-abi-call ;

: caller-stack-cleanup ( params stack-size -- cleanup )
    swap [ return>> ] [ abi>> ] bi stack-cleanup ;

: check-dlsym ( symbol library/f -- )
    {
        { [ dup library-dll dll-valid? not ] [
            [ library-dll dll-path ] [ dlerror>> ] bi
            cfg get word>> no-such-library-error drop
        ] }
        { [ 2dup library-dll dlsym not ] [
            drop dlerror cfg get word>> no-such-symbol-error
        ] }
        [ 2drop ]
    } cond ;

: caller-linkage ( params -- symbol dll/f )
    [ function>> ] [ library>> lookup-library ] bi
    2dup check-dlsym library-dll ;

: (caller-return) ( params -- )
    return>> [ ] [
        [
            building get last reg-outputs>>
            flip [ { } { } ] [ first2 ] if-empty
        ] dip
        base-type box-return ds-push
    ] if-void ;

: caller-return ( params -- )
    dup '[ _ (caller-return) ] with-abi-call ;

: insert-trampoline-area ( stack-size cpu -- stack-size' )
    dup mips? over alpha.64? or [ drop dup 0 = [ 16 align 32 + ] unless ] [
        dup name>> "s390x" = [
            drop dup 0 = [ 16 align 176 + ] unless
        ] [
            dup arm.64? over arm.32? or over sh? or over riscv? or over openrisc.32? or swap loongarch.64? or [ dup 0 = [ 16 align 16 + ] unless ] when
        ] if
    ] if ;

: ?insert-trampoline ( stack-size -- stack-size' ) cpu insert-trampoline-area ;

: params>alien-insn-params ( params --
                             varargs? reg-inputs stack-inputs
                             reg-outputs dead-outputs
                             cleanup stack-size )
    {
        [ varargs?>> ]
        [ caller-parameters ]
        [ prepare-caller-return { } ]
        [ stack-params get ?insert-trampoline [ caller-stack-cleanup ] keep ]
    } cleave ;

M: #alien-invoke emit-node
    dup params>> check-floating-point-signature
    params>>
    [
        [ params>alien-insn-params ]
        [ caller-linkage ] bi
        <gc-map> ##alien-invoke,
    ]
    [ caller-return ] bi ;

M: #alien-indirect emit-node
    dup params>> check-floating-point-signature
    params>>
    [
        [ ds-pop ^^unbox-any-c-ptr ] dip
        params>alien-insn-params
        <gc-map> ##alien-indirect,
    ]
    [ caller-return ] bi ;

M: #alien-assembly emit-node
    dup params>> check-floating-point-signature
    params>>
    [
        [ params>alien-insn-params ]
        [ quot>> ] bi
        ##alien-assembly,
    ]
    [ caller-return ] bi ;

: callee-parameter ( rep on-stack? odd-register? size -- dst )
    [ next-vreg dup ] 4dip next-parameter ;

: prepare-struct-callee ( c-type -- vreg )
    large-struct?
    [
        struct-return-stack-offset [
            [ next-vreg dup int-rep ] dip cell 4array stack-values get push
        ] [
            struct-return-register [
                [ next-vreg dup int-rep ] dip 3array reg-values get push
            ] [ int-rep struct-return-on-stack? f cell callee-parameter ] if*
        ] if*
    ] [ f ] if ;

: (callee-parameters) ( params -- vregs reps )
    [ flatten-parameter-type ] map
    [ [ [ dup prepare-parameter-group [ first3 ] [ param-natural-size ] bi callee-parameter ] map ] map ]
    [ [ keys ] map ] bi ;

:: (box-parameters) ( vregs reps params -- )
    params varargs?>> os windows? cpu arm.64? and and [
        vregs reps params parameters>>
        [ base-type box-windows-vararg-parameter ds-push ] 3each
    ] [
        vregs reps params parameters>> [ base-type box-parameter ds-push ] 3each
    ] if ;

:: box-parameters ( vregs reps params -- )
    params [ vregs reps params (box-parameters) ] with-abi-call ;

:: named-callee-parameters ( params -- vregs reps )
    params varargs?>> os windows? cpu arm.64? and and [
        params parameters>> [ base-type flatten-windows-vararg-type ] map
        [ [ [ dup prepare-parameter-group [ first3 ] [ param-natural-size ] bi callee-parameter ] map ] map ]
        [ [ keys ] map ] bi
    ] [ params parameters>> [ base-type ] map (callee-parameters) ] if ;

:: callee-parameters ( params -- vregs reps layout reg-outputs stack-outputs )
    params abi>> [
        params prepare-abi-call
        params return>> prepare-struct-callee struct-return-area set
        cpu riscv? cpu loongarch.64? or cpu mips? or struct-return-area get and [ 1 int-reg-reps set ] when
        params handle-varargs-named-count
        params named-callee-parameters
        params varargs?>> [
            stack-params get cpu riscv.32? cpu mips32? or cpu hppa? or 4 8 ? align
            int-regs get length float-regs get length 3array
        ] [ f ] if
    ] with-param-regs ;

! Calls emitted inside a callback have their own structure result areas.
! Keep the incoming C caller's pointer for the callback's eventual return.
SYMBOL: callback-struct-return-area

:: (callee-return) ( params -- reg-inputs )
    params return>> [ { } ] [
        [ ds-pop ] dip
        base-type dup [
            callback-struct-return-area get struct-return-area
            [ unbox-return ] with-variable
        ] dip store-callback-return
    ] if-void ;

: callee-return ( params -- reg-inputs )
    dup '[ _ (callee-return) ] with-abi-call ;

: emit-callback-body ( block nodes -- block' )
    dup last #return? t assert= but-last emit-nodes ;

:: emit-s390x-va-cursor-inputs ( entry-sp stack-offset gp-left fp-left -- )
    ! callback-stack points at the end of the ordinary 320-byte frame.
    ! The variadic frame extends it by 192, followed by Linux's save area.
    entry-sp stack-offset 352 + ^^add-imm ^^box-alien ds-push
    entry-sp 56 ^^add-imm ^^box-alien ds-push
    entry-sp 160 ^^add-imm ^^box-alien ds-push
    gp-left -8 * ^^load-literal ds-push
    fp-left -8 * ^^load-literal ds-push ;

:: emit-hppa-va-stack ( entry-sp stack-offset -- cursor )
    ! callback-stack exposes the original incoming native SP.
    entry-sp stack-offset 32 + ^^sub-imm ;

:: emit-va-cursor-inputs ( layout -- )
    layout first3 :> ( stack-offset gp-left fp-left )
    ! Hats can be regenerating its helper words while an image refreshes.
    next-vreg dup ##callback-stack, :> entry-sp
    cpu s390x? [
        entry-sp stack-offset gp-left fp-left emit-s390x-va-cursor-inputs
    ] [
        cpu hppa? [
            ! PA32 va_list points above the next descending argument slot.
            entry-sp stack-offset emit-hppa-va-stack
        ] [ cpu arm.32? [
            entry-sp gp-left 0 >
            [ 4 gp-left - cells ] [ 16 stack-offset + ] if ^^add-imm
        ] [
            cpu mips64? [
                ! MIPS stubs snapshot eight argument GPRs below incoming SP.
                entry-sp 8 gp-left - cells stack-offset + ^^add-imm
            ] [
                os windows? cpu riscv? cpu loongarch.64? or or gp-left 0 > and
                [ entry-sp gp-left cells ^^sub-imm ]
                [ entry-sp stack-offset ^^add-imm ] if
            ] if
        ] if ] if
        ^^box-alien ds-push
        os aapcs64-va-list-platform? cpu arm.64? and [
            entry-sp ^^box-alien ds-push
            entry-sp 64 ^^sub-imm ^^box-alien ds-push
            gp-left -8 * ^^load-literal ds-push
            fp-left -16 * ^^load-literal ds-push
        ] [
            f ^^load-literal ds-push f ^^load-literal ds-push
            0 ^^load-literal ds-push 0 ^^load-literal ds-push
        ] if
    ] if ;

:: emit-callback-inputs ( params -- )
    params callee-parameters :> ( vregs reps layout reg-outputs stack-outputs )
    struct-return-area get callback-struct-return-area set
    reg-outputs stack-outputs layout cpu mips? cpu hppa? or cpu m88k? or not and [
        [ first4 [ cpu riscv? cpu loongarch.64? or [ 8 cells ] [ 192 ] if + ] dip 4array ] map
    ] when ##callback-inputs,
    vregs reps params box-parameters
    layout [ emit-va-cursor-inputs ] when* ;

: callback-stack-cleanup ( params -- )
    [ xt>> ]
    [ [ stack-params get ] dip [ return>> ] [ abi>> ] bi stack-cleanup ] bi
    "stack-cleanup" set-word-prop ;

: emit-callback-return ( block params -- )
    swap [ callee-return ##callback-outputs, ] [ drop ] if ;

: emit-callback-outputs ( block params -- )
    [ emit-callback-return ] keep callback-stack-cleanup ;

M: #alien-callback emit-node
    dup params>> check-floating-point-signature
    dup params>> xt>> dup
    [
        t cfg get frame-pointer?<<
        begin-word
        over params>> emit-callback-inputs
        over child>> emit-callback-body
        [ swap params>> emit-callback-outputs ] keep
        [ end-word drop ] when*
    ] with-cfg-builder ;
