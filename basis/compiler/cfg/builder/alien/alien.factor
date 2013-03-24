! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors assocs arrays layouts math math.order
math.parser combinators combinators.short-circuit fry make
sequences sequences.generalizations alien alien.private
alien.strings alien.c-types alien.libraries classes.struct
namespaces kernel strings libc locals quotations words
cpu.architecture compiler.utilities compiler.tree compiler.cfg
compiler.cfg.builder compiler.cfg.builder.alien.params
compiler.cfg.builder.alien.boxing compiler.cfg.builder.blocks
compiler.cfg.instructions compiler.cfg.stack-frame
compiler.cfg.stacks compiler.cfg.stacks.local
compiler.cfg.registers compiler.cfg.hats compiler.errors ;
FROM: compiler.errors => no-such-symbol no-such-library ;
IN: compiler.cfg.builder.alien

: with-param-regs* ( quot -- reg-values stack-values )
    '[
        V{ } clone reg-values set
        V{ } clone stack-values set
        @
        reg-values get
        stack-values get
        stack-params get
        struct-return-area get
    ] with-param-regs
    struct-return-area set
    stack-params set ; inline

: unbox-parameters ( parameters -- vregs reps )
    [
        [ length iota <reversed> ] keep
        [ [ <ds-loc> peek-loc ] [ base-type ] bi* unbox-parameter ]
        2 2 mnmap [ concat ] bi@
    ]
    [ length neg inc-d ] bi ;

: prepare-struct-caller ( vregs reps return -- vregs' reps' return-vreg/f )
    dup large-struct? [
        heap-size cell f ^^local-allot [
            '[ _ prefix ]
            [ int-rep struct-return-on-stack? f 3array prefix ] bi*
        ] keep
    ] [ drop f ] if ;

: (caller-parameters) ( vregs reps -- )
    [ first3 next-parameter ] 2each ;

: caller-parameters ( params -- reg-inputs stack-inputs )
    [ abi>> ] [ parameters>> ] [ return>> ] tri
    '[ 
        _ unbox-parameters
        _ prepare-struct-caller struct-return-area set
        (caller-parameters)
    ] with-param-regs* ;

: prepare-caller-return ( params -- reg-outputs dead-outputs )
    return>> [ { } ] [ base-type load-return ] if-void { } ;

: caller-stack-frame ( params -- cleanup stack-size )
    [ stack-params get ] dip [ return>> ] [ abi>> ] bi stack-cleanup
    stack-params get ;

GENERIC# dlsym-valid? 1 ( symbols dll -- ? )

M: string dlsym-valid? dlsym ;

M: array dlsym-valid? '[ _ dlsym ] any? ;

: check-dlsym ( symbols library -- )
    {
        { [ dup library-dll dll-valid? not ] [
            [ library-dll dll-path ] [ dlerror>> ] bi
            cfg get word>> no-such-library-error drop 
        ] }
        { [ 2dup library-dll dlsym-valid? not ] [
            drop dlerror cfg get word>> no-such-symbol-error
        ] }
        [ 2drop ]
    } cond ;

: decorated-symbol ( params -- symbols )
    [ function>> ] [ parameters>> [ stack-size ] map-sum number>string ] bi
    {
        [ drop ]
        [ "@" glue ]
        [ "@" glue "_" prepend ]
        [ "@" glue "@" prepend ]
    } 2cleave
    4array ;

: caller-linkage ( params -- symbols dll )
    [ dup abi>> callee-cleanup? [ decorated-symbol ] [ function>> ] if ]
    [ library>> lookup-library ]
    bi 2dup check-dlsym library-dll ;

: caller-return ( params -- )
    return>> [ ] [
        [
            building get last reg-outputs>>
            flip [ { } { } ] [ first2 ] if-empty
        ] dip
        base-type box-return ds-push
    ] if-void ;

M: #alien-invoke emit-node
    params>>
    [
        {
            [ caller-parameters ]
            [ prepare-caller-return ]
            [ caller-stack-frame ]
            [ caller-linkage ]
        } cleave
        <gc-map> ##alien-invoke,
    ]
    [ caller-return ]
    bi ;

M: #alien-indirect emit-node ( node -- )
    params>>
    [
        [ ds-pop ^^unbox-any-c-ptr ] dip
        [ caller-parameters ]
        [ prepare-caller-return ]
        [ caller-stack-frame ] tri
        <gc-map> ##alien-indirect,
    ]
    [ caller-return ]
    bi ;

M: #alien-assembly emit-node
    params>>
    [
        {
            [ caller-parameters ]
            [ prepare-caller-return ]
            [ caller-stack-frame ]
            [ quot>> ]
        } cleave <gc-map> ##alien-assembly,
    ]
    [ caller-return ]
    bi ;

: callee-parameter ( rep on-stack? odd-register? -- dst )
    [ next-vreg dup ] 3dip next-parameter ;

: prepare-struct-callee ( c-type -- vreg )
    large-struct?
    [ int-rep struct-return-on-stack? f callee-parameter ] [ f ] if ;

: (callee-parameters) ( params -- vregs reps )
    [ flatten-parameter-type ] map
    [ [ [ first3 callee-parameter ] map ] map ]
    [ [ keys ] map ]
    bi ;

: box-parameters ( vregs reps params -- )
    parameters>> [ base-type box-parameter ds-push ] 3each ;

: callee-parameters ( params -- vregs reps reg-outputs stack-outputs )
    [ abi>> ] [ return>> ] [ parameters>> ] tri
    '[ 
        _ prepare-struct-callee struct-return-area set
        _ [ base-type ] map (callee-parameters)
    ] with-param-regs* ;

: callee-return ( params -- reg-inputs )
    return>> [ { } ] [
        [ ds-pop ] dip
        base-type unbox-return store-return
    ] if-void ;

: callback-stack-cleanup ( params -- )
    [ xt>> ]
    [ [ stack-params get ] dip [ return>> ] [ abi>> ] bi stack-cleanup ] bi
    "stack-cleanup" set-word-prop ;

: needs-frame-pointer ( -- )
    cfg get t >>frame-pointer? drop ;

: emit-callback-body ( nodes -- )
    [ last #return? t assert= ] [ but-last emit-nodes ] bi ;

: emit-callback-return ( params -- )
    basic-block get [ callee-return ##callback-outputs, ] [ drop ] if ;

M: #alien-callback emit-node
    dup params>> xt>> dup
    [
        needs-frame-pointer

        begin-word

        {
            [ params>> callee-parameters ##callback-inputs, ]
            [ params>> box-parameters ]
            [ child>> emit-callback-body ]
            [ params>> emit-callback-return ]
            [ params>> callback-stack-cleanup ]
        } cleave

        basic-block get [ end-word ] when
    ] with-cfg-builder ;
