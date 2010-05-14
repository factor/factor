! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays layouts math math.order math.parser
combinators combinators.short-circuit fry make sequences locals
alien alien.private alien.strings alien.c-types alien.libraries
classes.struct namespaces kernel strings libc quotations words
cpu.architecture compiler.utilities compiler.tree compiler.cfg
compiler.cfg.builder compiler.cfg.builder.alien.params
compiler.cfg.builder.blocks compiler.cfg.instructions
compiler.cfg.stack-frame compiler.cfg.stacks
compiler.cfg.registers compiler.cfg.hats ;
FROM: compiler.errors => no-such-symbol no-such-library ;
IN: compiler.cfg.builder.alien

! output is triples with shape { vreg rep on-stack? }
GENERIC: unbox ( src c-type -- vregs )

M: c-type unbox
    [ [ unboxer>> ] [ rep>> ] bi ^^unbox ] [ rep>> ] bi
    f 3array 1array ;

M: long-long-type unbox
    unboxer>> int-rep ^^unbox
    0 cell
    [
        int-rep f ^^load-memory-imm
        int-rep long-long-on-stack? 3array
    ] bi-curry@ bi 2array ;

GENERIC: unbox-parameter ( src c-type -- vregs )

M: c-type unbox-parameter unbox ;

M: long-long-type unbox-parameter unbox ;

M:: struct-c-type unbox-parameter ( src c-type -- )
    src ^^unbox-any-c-ptr :> src
    c-type value-struct? [
        c-type flatten-struct-type
        [| pair i |
            src i cells pair first f ^^load-memory-imm
            pair first2 3array
        ] map-index
    ] [ { { src int-rep f } } ] if ;

: unbox-parameters ( parameters -- vregs )
    [
        [ length iota <reversed> ] keep
        [
            [ <ds-loc> ^^peek ] [ base-type ] bi*
            unbox-parameter
        ] 2map concat
    ]
    [ length neg ##inc-d ] bi ;

: prepare-struct-area ( vregs return -- vregs )
    #! Return offset on C stack where to store unboxed
    #! parameters. If the C function is returning a structure,
    #! the first parameter is an implicit target area pointer,
    #! so we need to use a different offset.
    large-struct? [
        ^^prepare-struct-area int-rep struct-return-on-stack?
        3array prefix
    ] when ;

: (objects>registers) ( vregs -- )
    ! Place ##store-stack-param instructions first. This ensures
    ! that no registers are used after the ##store-reg-param
    ! instructions.
    [
        first3 [ dup reg-class-of reg-class-full? ] dip or
        [ [ alloc-stack-param ] keep \ ##store-stack-param new-insn ]
        [ [ next-reg-param ] keep \ ##store-reg-param new-insn ]
        if
    ] map [ ##store-stack-param? ] partition [ % ] bi@ ;

: objects>registers ( params -- stack-size )
    [ abi>> ] [ parameters>> ] [ return>> ] tri
    '[ 
        _ unbox-parameters
        _ prepare-struct-area
        (objects>registers)
        stack-params get
    ] with-param-regs ;

GENERIC: box-return ( c-type -- dst )

M: c-type box-return
    [ f ] dip [ rep>> ] [ boxer>> ] bi ^^box ;

M: long-long-type box-return
    [ f ] dip boxer>> ^^box-long-long ;

M: struct-c-type box-return
    dup return-struct-in-registers?
    [ ^^box-small-struct ] [ [ f ] dip ^^box-large-struct ] if ;

: box-return* ( node -- )
    return>> [ ] [ base-type box-return 1 ##inc-d D 0 ##replace ] if-void ;

GENERIC# dlsym-valid? 1 ( symbols dll -- ? )

M: string dlsym-valid? dlsym ;

M: array dlsym-valid? '[ _ dlsym ] any? ;

: check-dlsym ( symbols dll -- )
    dup dll-valid? [
        dupd dlsym-valid?
        [ drop ] [ cfg get word>> no-such-symbol ] if
    ] [ dll-path cfg get word>> no-such-library drop ] if ;

: decorated-symbol ( params -- symbols )
    [ function>> ] [ parameters>> [ stack-size ] map-sum number>string ] bi
    {
        [ drop ]
        [ "@" glue ]
        [ "@" glue "_" prepend ]
        [ "@" glue "@" prepend ]
    } 2cleave
    4array ;

: alien-invoke-dlsym ( params -- symbols dll )
    [ dup abi>> callee-cleanup? [ decorated-symbol ] [ function>> ] if ]
    [ library>> load-library ]
    bi 2dup check-dlsym ;

: return-size ( c-type -- n )
    #! Amount of space we reserve for a return value.
    {
        { [ dup void? ] [ drop 0 ] }
        { [ dup base-type struct-c-type? not ] [ drop 0 ] }
        { [ dup large-struct? not ] [ drop 2 cells ] }
        [ heap-size ]
    } cond ;

: alien-node-height ( params -- )
    [ out-d>> length ] [ in-d>> length ] bi - adjust-d ;

: emit-alien-block ( node quot: ( params -- ) -- )
    '[
        make-kill-block
        params>>
        _ [ alien-node-height ] bi
    ] emit-trivial-block ; inline

: <alien-stack-frame> ( stack-size return -- stack-frame )
    stack-frame new
        swap return-size >>return
        swap >>params
        t >>calls-vm? ;

: emit-stack-frame ( stack-size params -- )
    [ return>> ] [ abi>> ] bi
    [ stack-cleanup ##cleanup ]
    [ drop <alien-stack-frame> ##stack-frame ] 3bi ;

M: #alien-invoke emit-node
    [
        {
            [ objects>registers ]
            [ alien-invoke-dlsym ##alien-invoke ]
            [ emit-stack-frame ]
            [ box-return* ]
        } cleave
    ] emit-alien-block ;

M:: #alien-indirect emit-node ( node -- )
    node [
        D 0 ^^peek -1 ##inc-d ^^unbox-any-c-ptr :> src
        {
            [ objects>registers ]
            [ drop src ##alien-indirect ]
            [ emit-stack-frame ]
            [ box-return* ]
        } cleave
    ] emit-alien-block ;

M: #alien-assembly emit-node
    [
        {
            [ objects>registers ]
            [ quot>> ##alien-assembly ]
            [ emit-stack-frame ]
            [ box-return* ]
        } cleave
    ] emit-alien-block ;

GENERIC: box-parameter ( n c-type -- dst )

M: c-type box-parameter
    [ rep>> ] [ boxer>> ] bi ^^box ;

M: long-long-type box-parameter
    boxer>> ^^box-long-long ;

: if-value-struct ( ctype true false -- )
    [ dup value-struct? ] 2dip '[ drop void* @ ] if ; inline

M: struct-c-type box-parameter
    [ ^^box-large-struct ] [ base-type box-parameter ] if-value-struct ;

: parameter-offsets ( types -- offsets )
    0 [ stack-size + ] accumulate nip ;

: prepare-parameters ( parameters -- offsets types indices )
    [ length iota <reversed> ] [ parameter-offsets ] [ ] tri ;

: alien-parameters ( params -- seq )
    [ parameters>> ] [ return>> large-struct? ] bi
    [ struct-return-on-stack? (stack-value) void* ? prefix ] when ;

: box-parameters ( params -- )
    alien-parameters
    [ length ##inc-d ]
    [
        prepare-parameters
        [
            next-vreg next-vreg ##save-context
            base-type box-parameter swap <ds-loc> ##replace
        ] 3each
    ] bi ;

:: alloc-parameter ( rep -- reg rep )
    rep dup reg-class-of reg-class-full?
    [ alloc-stack-param stack-params ] [ [ next-reg-param ] keep ] if ;

GENERIC: flatten-c-type ( type -- reps )

M: struct-c-type flatten-c-type
    flatten-struct-type [ first2 [ drop stack-params ] when ] map ;
    
M: long-long-type flatten-c-type drop { int-rep int-rep } ;

M: c-type flatten-c-type
    rep>> {
        { int-rep [ { int-rep } ] }
        { float-rep [ float-on-stack? { stack-params } { float-rep } ? ] }
        { double-rep [
            float-on-stack?
            cell 4 = { stack-params stack-params } { stack-params } ?
            { double-rep } ?
        ] }
        { stack-params [ { stack-params } ] }
    } case ;
    
M: object flatten-c-type base-type flatten-c-type ;

: flatten-c-types ( types -- reps )
    [ flatten-c-type ] map concat ;

: (registers>objects) ( params -- )
    [ 0 ] dip alien-parameters flatten-c-types [
        [ alloc-parameter ##save-param-reg ]
        [ rep-size cell align + ]
        2bi
    ] each drop ; inline

: registers>objects ( params -- )
    ! Generate code for boxing input parameters in a callback.
    dup abi>> [
        dup (registers>objects)
        ##begin-callback
        next-vreg next-vreg ##restore-context
        box-parameters
    ] with-param-regs ;

: callback-return-quot ( ctype -- quot )
    return>> {
        { [ dup void? ] [ drop [ ] ] }
        { [ dup large-struct? ] [ heap-size '[ _ memcpy ] ] }
        [ c-type c-type-unboxer-quot ]
    } cond ;

: callback-prep-quot ( params -- quot )
    parameters>> [ c-type c-type-boxer-quot ] map spread>quot ;

: wrap-callback-quot ( params -- quot )
    [ callback-prep-quot ] [ quot>> ] [ callback-return-quot ] tri 3append
     yield-hook get
     '[ _ _ do-callback ]
     >quotation ;

GENERIC: unbox-return ( src c-type -- )

M: c-type unbox-return
    unbox first first2 ##store-return ;

M: long-long-type unbox-return
    unbox first2 [ first ] bi@ ##store-long-long-return ;

M: struct-c-type unbox-return
    [ ^^unbox-any-c-ptr ] dip ##store-struct-return ;

: emit-callback-stack-frame ( params -- )
    [ alien-parameters [ stack-size ] map-sum ] [ return>> ] bi
    <alien-stack-frame> ##stack-frame ;

: stack-args-size ( params -- n )
    dup abi>> [
        alien-parameters flatten-c-types
        [ alloc-parameter 2drop ] each
        stack-params get
    ] with-param-regs ;

: callback-stack-cleanup ( params -- )
    [ xt>> ] [ [ stack-args-size ] [ return>> ] [ abi>> ] tri stack-cleanup ] bi
    "stack-cleanup" set-word-prop ;

M: #alien-callback emit-node
    dup params>> xt>> dup
    [
        ##prologue
        [
            {
                [ registers>objects ]
                [ emit-callback-stack-frame ]
                [ callback-stack-cleanup ]
                [ wrap-callback-quot ##alien-callback ]
                [
                    return>> {
                        { [ dup void? ] [ drop ##end-callback ] }
                        { [ dup large-struct? ] [ drop ##end-callback ] }
                        [
                            [ D 0 ^^peek ] dip
                            ##end-callback
                            base-type unbox-return
                        ]
                    } cond
                ]
            } cleave
        ] emit-alien-block
        ##epilogue
        ##return
    ] with-cfg-builder ;
