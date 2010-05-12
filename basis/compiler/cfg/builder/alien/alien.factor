! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays layouts math math.order math.parser
combinators fry make sequences locals alien alien.private
alien.strings alien.c-types alien.libraries classes.struct
namespaces kernel strings libc quotations cpu.architecture
compiler.alien compiler.utilities compiler.tree compiler.cfg
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
    ! Place instructions in reverse order, so that the
    ! ##store-stack-param instructions come first. This is
    ! because they are not clobber-insns and so we avoid some
    ! spills that way.
    [
        first3 [ dup reg-class-of reg-class-full? ] dip or
        [ [ alloc-stack-param ] keep \ ##store-stack-param new-insn ]
        [ [ next-reg-param ] keep \ ##store-reg-param new-insn ]
        if
    ] map reverse % ;

: objects>registers ( params -- )
    #! Generate code for unboxing a list of C types, then
    #! generate code for moving these parameters to registers on
    #! architectures where parameters are passed in registers.
    [ abi>> ] [ parameters>> ] [ return>> ] tri
    '[ 
        _ unbox-parameters
        _ prepare-struct-area
        (objects>registers)
    ] with-param-regs ;

GENERIC: box-return ( c-type -- dst )

M: c-type box-return
    [ f ] dip [ rep>> ] [ boxer>> ] bi ^^box ;

M: long-long-type box-return
    [ f ] dip boxer>> ^^box-long-long ;

: if-small-struct ( c-type true false -- ? )
    [ dup return-struct-in-registers? ] 2dip '[ f swap @ ] if ; inline

M: struct-c-type box-return
    [ ^^box-small-struct ] [ ^^box-large-struct ] if-small-struct ;

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

: return-size ( ctype -- n )
    #! Amount of space we reserve for a return value.
    {
        { [ dup c-struct? not ] [ drop 0 ] }
        { [ dup large-struct? not ] [ drop 2 cells ] }
        [ heap-size ]
    } cond ;

: <alien-stack-frame> ( params -- stack-frame )
    stack-frame new
        swap
        [ return>> return-size >>return ]
        [ alien-parameters [ stack-size ] map-sum >>params ] bi
        t >>calls-vm? ;

: alien-node-height ( params -- )
    [ out-d>> length ] [ in-d>> length ] bi - adjust-d ;

: emit-alien-node ( node quot -- )
    '[
        make-kill-block
        params>>
        [ <alien-stack-frame> ##stack-frame ]
        _
        [ alien-node-height ]
        tri
    ] emit-trivial-block ; inline

M: #alien-invoke emit-node
    [
        {
            [ objects>registers ]
            [ alien-invoke-dlsym ##alien-invoke ]
            [ stack-cleanup ##cleanup ]
            [ box-return* ]
        } cleave
    ] emit-alien-node ;

M: #alien-indirect emit-node
    [
        D 0 ^^peek -1 ##inc-d ^^unbox-any-c-ptr
        {
            [ drop objects>registers ]
            [ nip ##alien-indirect ]
            [ drop stack-cleanup ##cleanup ]
            [ drop box-return* ]
        } 2cleave
    ] emit-alien-node ;

M: #alien-assembly emit-node
    [
        [ objects>registers ]
        [ quot>> ##alien-assembly ]
        [ box-return* ]
        tri
    ] emit-alien-node ;

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
M: c-type flatten-c-type rep>> 1array ;
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

M: #alien-callback emit-node
    dup params>> xt>> dup
    [
        ##prologue
        [
            [ registers>objects ]
            [ wrap-callback-quot ##alien-callback ]
            [
                return>> {
                    { [ dup void eq? ] [ drop ##end-callback ] }
                    { [ dup large-struct? ] [ drop ##end-callback ] }
                    [
                        [ D 0 ^^peek ] dip
                        ##end-callback
                        base-type unbox-return
                    ]
                } cond
            ] tri
        ] emit-alien-node
        ##epilogue
        ##return
    ] with-cfg-builder ;
