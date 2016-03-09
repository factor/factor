! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien.c-types alien.libraries alien.strings arrays
assocs classes.struct combinators compiler.cfg compiler.cfg.builder
compiler.cfg.builder.alien.boxing compiler.cfg.builder.alien.params
compiler.cfg.hats compiler.cfg.instructions compiler.cfg.registers
compiler.cfg.stacks compiler.cfg.stacks.local compiler.errors
compiler.tree cpu.architecture fry kernel layouts make math namespaces
sequences sequences.generalizations words ;
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
    [ length neg <ds-loc> inc-stack ] bi ;

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

: check-dlsym ( symbol library -- )
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

: caller-linkage ( params -- symbol dll )
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

M: #alien-invoke emit-node ( block node -- block' )
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
    [ caller-return ] bi ;

M: #alien-indirect emit-node ( block node -- block' )
    params>>
    [
        [ ds-pop ^^unbox-any-c-ptr ] dip
        [ caller-parameters ]
        [ prepare-caller-return ]
        [ caller-stack-frame ] tri
        <gc-map> ##alien-indirect,
    ]
    [ caller-return ] bi ;

M: #alien-assembly emit-node ( block node -- block' )
    params>>
    [
        {
            [ caller-parameters ]
            [ prepare-caller-return ]
            [ caller-stack-frame ]
            [ quot>> ]
        } cleave ##alien-assembly,
    ]
    [ caller-return ] bi ;

: callee-parameter ( rep on-stack? odd-register? -- dst )
    [ next-vreg dup ] 3dip next-parameter ;

: prepare-struct-callee ( c-type -- vreg )
    large-struct?
    [ int-rep struct-return-on-stack? f callee-parameter ] [ f ] if ;

: (callee-parameters) ( params -- vregs reps )
    [ flatten-parameter-type ] map
    [ [ [ first3 callee-parameter ] map ] map ]
    [ [ keys ] map ] bi ;

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

M: #alien-callback emit-node ( block node -- block' )
    dup params>> xt>> dup
    [
        t cfg get frame-pointer?<<
        begin-word
        over params>> emit-callback-inputs
        over child>> emit-callback-body
        [ swap params>> emit-callback-outputs ] keep
        [ end-word drop ] when*
    ] with-cfg-builder ;
