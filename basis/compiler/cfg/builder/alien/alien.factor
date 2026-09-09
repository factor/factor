! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.libraries alien.strings arrays
assocs classes.struct combinators compiler.cfg compiler.cfg.builder
compiler.cfg.builder.alien.boxing compiler.cfg.builder.alien.params
compiler.cfg.hats compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.stacks compiler.cfg.stacks.local compiler.errors
compiler.tree cpu.architecture kernel layouts locals make math math.order namespaces
sequences sequences.generalizations stack-checker.alien system
words ;
IN: compiler.cfg.builder.alien

: with-param-regs ( abi quot -- reg-values stack-values )
    '[
        param-regs init-regs
        0 stack-params set
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
                dup struct-c-type? [ frob-struct ] when
                c-type-align mark-vararg-group ] [ reps ] if
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
    [ [ <ds-loc> peek-loc ] [ base-type ] bi* unbox-parameter ]
    2 2 mnmap parameters mark-varargs [ concat ] bi@
    windows-arm64-varargs? get [ windows-vararg-parameters ] when
    parameters length neg <ds-loc> inc-stack ;

:: prepare-struct-caller ( vregs reps return -- vregs' reps' return-vreg/f )
    return large-struct? [
        return [ heap-size ] [ c-type-align cell max ] bi f ^^local-allot :> result
        struct-return-register [
            result int-rep rot 3array reg-values get push
            vregs reps
        ] [
            vregs result prefix
            reps int-rep struct-return-on-stack? f 3array prefix
        ] if* result
    ] [ vregs reps f ] if ;

: handle-macos-arm64-varargs ( params -- )
    varargs?>> os macos? cpu arm.64? and [ drop f ] unless
    varargs-named-count set ;

: start-vararg ( alignment -- )
    ! Apple rounds the named stack area and each variadic argument to
    ! eight-byte slots; over-aligned aggregates also retain their C alignment.
    int-regs get delete-all float-regs get delete-all
    8 max '[ _ align ] stack-params swap change ;

:: caller-parameter ( vreg rep -- )
    rep length 8 = [ 5 rep nth [ 7 rep nth start-vararg ] when ] when
    rep prepare-parameter-group
    vreg rep first3 rep param-natural-size next-parameter
    rep length 8 = [ 6 rep nth [ stack-params [ 8 align ] change ] when ] when ;

: (caller-parameters) ( vregs reps -- )
    [ caller-parameter ] 2each ;

: windows-arm64-varargs-call? ( params -- ? )
    varargs?>> >boolean os windows? cpu arm.64? and and ;

: caller-parameters ( params -- reg-inputs stack-inputs )
    {
        [ abi>> ]
        [ ]
        [ windows-arm64-varargs-call? ]
        [ parameters>> ]
        [ return>> ]
    } cleave
    '[
        _ handle-macos-arm64-varargs
        _ windows-arm64-varargs? [ _ unbox-parameters ] with-variable
        _ prepare-struct-caller struct-return-area set
        (caller-parameters)
    ] with-param-regs ;

: prepare-caller-return ( params -- reg-outputs )
    return>> [ { } ] [ base-type load-return ] if-void ;

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

: caller-return ( params -- )
    return>> [ ] [
        [
            building get last reg-outputs>>
            flip [ { } { } ] [ first2 ] if-empty
        ] dip
        base-type box-return ds-push
    ] if-void ;

: ?insert-trampoline ( stack-size -- stack-size' )
    cpu arm.64? [ dup 0 = [ 16 align 16 + ] unless ] when ;

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
    params>>
    [
        [ params>alien-insn-params ]
        [ caller-linkage ] bi
        <gc-map> ##alien-invoke,
    ]
    [ caller-return ] bi ;

M: #alien-indirect emit-node
    params>>
    [
        [ ds-pop ^^unbox-any-c-ptr ] dip
        params>alien-insn-params
        <gc-map> ##alien-indirect,
    ]
    [ caller-return ] bi ;

M: #alien-assembly emit-node
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
        struct-return-register [
            [ next-vreg dup int-rep ] dip 3array reg-values get push
        ] [ int-rep struct-return-on-stack? f cell callee-parameter ] if*
    ] [ f ] if ;

: (callee-parameters) ( params -- vregs reps )
    [ flatten-parameter-type ] map
    [ [ [ dup prepare-parameter-group [ first3 ] [ param-natural-size ] bi callee-parameter ] map ] map ]
    [ [ keys ] map ] bi ;

:: box-parameters ( vregs reps params -- )
    params varargs?>> os windows? cpu arm.64? and and [
        vregs reps params parameters>>
        [ base-type box-windows-vararg-parameter ds-push ] 3each
    ] [
        vregs reps params parameters>> [ base-type box-parameter ds-push ] 3each
    ] if ;

:: named-callee-parameters ( params -- vregs reps )
    params varargs?>> os windows? cpu arm.64? and and [
        params parameters>> [ base-type flatten-windows-vararg-type ] map
        [ [ [ dup prepare-parameter-group [ first3 ] [ param-natural-size ] bi callee-parameter ] map ] map ]
        [ [ keys ] map ] bi
    ] [ params parameters>> [ base-type ] map (callee-parameters) ] if ;

:: callee-parameters ( params -- vregs reps layout reg-outputs stack-outputs )
    params abi>> [
        params return>> prepare-struct-callee struct-return-area set
        params named-callee-parameters
        params varargs?>> [
            stack-params get 8 align
            int-regs get length float-regs get length 3array
        ] [ f ] if
    ] with-param-regs ;

! Calls emitted inside a callback have their own structure result areas.
! Keep the incoming C caller's pointer for the callback's eventual return.
SYMBOL: callback-struct-return-area

: callee-return ( params -- reg-inputs )
    return>> [ { } ] [
        [ ds-pop ] dip
        base-type callback-struct-return-area get struct-return-area
        [ unbox-return ] with-variable store-return
    ] if-void ;

: emit-callback-body ( block nodes -- block' )
    dup last #return? t assert= but-last emit-nodes ;

:: emit-va-cursor-inputs ( layout -- )
    layout first3 :> ( stack-offset gp-left fp-left )
    ^^callback-stack :> entry-sp
    os windows? gp-left 0 > and
    [ entry-sp gp-left 8 * ^^sub-imm ]
    [ entry-sp stack-offset ^^add-imm ] if ^^box-alien ds-push
    os linux? [
        entry-sp ^^box-alien ds-push
        entry-sp 64 ^^sub-imm ^^box-alien ds-push
        gp-left -8 * ^^load-literal ds-push
        fp-left -16 * ^^load-literal ds-push
    ] [
        f ^^load-literal ds-push f ^^load-literal ds-push
        0 ^^load-literal ds-push 0 ^^load-literal ds-push
    ] if ;

:: emit-callback-inputs ( params -- )
    params callee-parameters :> ( vregs reps layout reg-outputs stack-outputs )
    struct-return-area get callback-struct-return-area set
    reg-outputs stack-outputs layout [
        [ first4 [ 192 + ] dip 4array ] map
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
    dup params>> xt>> dup
    [
        t cfg get frame-pointer?<<
        begin-word
        over params>> emit-callback-inputs
        over child>> emit-callback-body
        [ swap params>> emit-callback-outputs ] keep
        [ end-word drop ] when*
    ] with-cfg-builder ;
