! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.libraries alien.strings arrays
assocs classes.struct combinators compiler.cfg compiler.cfg.builder
compiler.cfg.builder.alien.boxing compiler.cfg.builder.alien.params
compiler.cfg.hats compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.stacks compiler.cfg.stacks.local compiler.errors
compiler.tree cpu.architecture kernel layouts make math math.order namespaces
locals sequences sequences.generalizations stack-checker.alien system
words ;
IN: compiler.cfg.builder.alien

: with-param-regs ( abi quot -- reg-values stack-values )
    '[
        param-regs init-regs
        0 stack-params set
        0 stack-param-group-remaining set
        0 stack-param-group-next set
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

: unbox-parameters ( parameters -- vregs reps )
    [
        [ length <iota> <reversed> ] keep
        [ [ <ds-loc> peek-loc ] [ base-type ] bi* unbox-parameter ]
        2 2 mnmap [ concat ] bi@
    ]
    [ length neg <ds-loc> inc-stack ] bi ;

:: prepare-struct-caller ( vregs reps return -- vregs' reps' return-vreg/f )
    return large-struct? [
        return heap-size cell f ^^local-allot :> return-vreg
        struct-return-reg :> return-reg
        return-reg [
            return-vreg int-rep return-reg 3array reg-values get push
            vregs reps return-vreg
        ] [
            return-vreg vregs prefix
            int-rep struct-return-on-stack? f 3array reps prefix
            return-vreg
        ] if
    ] [ vregs reps f ] if ;

: parameter-component-count ( parameters -- n )
    0 int-reg-reps [
        0 float-reg-reps [
            [ base-type flatten-parameter-type length ] map-sum
        ] with-variable
    ] with-variable ;

:: macos-arm64-varargs-boundary ( params -- n/f )
    os macos? cpu arm.64? and params alien-invoke-params? and [
        params varargs?>> dup integer? [
            params parameters>> swap head parameter-component-count
        ] [
            drop params function>> { "fcntl" "open" } member? 2 f ?
        ] if
    ] [ f ] if ;

:: caller-parameter ( vreg rep-tuple force-stack? -- )
    vreg
    rep-tuple first
    rep-tuple second force-stack? or
    rep-tuple third
    rep-tuple param-natural-size
    rep-tuple param-signed?
    next-parameter ;

:: (caller-parameters) ( vregs reps boundary -- )
    boundary integer? [
        vregs boundary head
        reps boundary head
        [ f caller-parameter ] 2each

        f compact-stack-params? set
        vregs boundary tail
        reps boundary tail
        [ t caller-parameter ] 2each
    ] [
        vregs reps [ f caller-parameter ] 2each
    ] if ;

: caller-parameters ( params -- reg-inputs stack-inputs )
    {
        [ abi>> ]
        [ parameters>> ]
        [ return>> ]
        [ ]
    } cleave
    '[
        _ unbox-parameters
        _ prepare-struct-caller struct-return-area set
        _ macos-arm64-varargs-boundary
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

:: callee-parameter ( rep on-stack? register-requirement size signed? -- dst )
    next-vreg :> dst
    dst dst rep on-stack? register-requirement size signed? next-parameter ;

:: prepare-struct-callee ( c-type -- vreg )
    c-type large-struct? [
        struct-return-reg :> return-reg
        return-reg [
            next-vreg :> vreg
            vreg int-rep return-reg 3array reg-values get push
            vreg
        ] [ int-rep struct-return-on-stack? f cell f callee-parameter ] if
    ] [ f ] if ;

: (callee-parameters) ( params -- vregs reps )
    [ flatten-parameter-type ] map
    [
        [
            [
                [ first3 ] [ param-natural-size ] [ param-signed? ] tri
                callee-parameter
            ] map
        ] map
    ]
    [ [ keys ] map ] bi ;

: box-parameters ( vregs reps params -- )
    parameters>> [ base-type box-parameter ds-push ] 3each ;

: callee-parameters ( params -- vregs reps reg-outputs stack-outputs )
    [ abi>> ] [ return>> ] [ parameters>> ] tri
    '[
        _ prepare-struct-callee struct-return-area set
        _ [ base-type ] map (callee-parameters)
    ] with-param-regs ;

: callee-return ( params -- reg-inputs )
    return>> [ { } ] [
        [ ds-pop ] dip
        base-type unbox-return store-return
    ] if-void ;

: emit-callback-body ( block nodes -- block' )
    dup last #return? t assert= but-last emit-nodes ;

: emit-callback-inputs ( params -- )
    [ callee-parameters ##callback-inputs, ] keep box-parameters ;

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
