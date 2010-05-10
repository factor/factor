! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays layouts math math.order math.parser
combinators fry sequences locals alien alien.private
alien.strings alien.c-types alien.libraries classes.struct
namespaces kernel strings libc quotations cpu.architecture
compiler.alien compiler.utilities compiler.tree compiler.cfg
compiler.cfg.builder compiler.cfg.builder.blocks
compiler.cfg.instructions compiler.cfg.stack-frame
compiler.cfg.stacks compiler.cfg.registers
compiler.cfg.hats ;
FROM: compiler.errors => no-such-symbol no-such-library ;
IN: compiler.cfg.builder.alien

GENERIC: next-fastcall-param ( rep -- )

: ?dummy-stack-params ( rep -- )
    dummy-stack-params? [ rep-size cell align stack-params +@ ] [ drop ] if ;

: ?dummy-int-params ( rep -- )
    dummy-int-params? [ rep-size cell /i 1 max int-regs +@ ] [ drop ] if ;

: ?dummy-fp-params ( rep -- )
    drop dummy-fp-params? [ float-regs inc ] when ;

M: int-rep next-fastcall-param
    int-regs inc [ ?dummy-stack-params ] [ ?dummy-fp-params ] bi ;

M: float-rep next-fastcall-param
    float-regs inc [ ?dummy-stack-params ] [ ?dummy-int-params ] bi ;

M: double-rep next-fastcall-param
    float-regs inc [ ?dummy-stack-params ] [ ?dummy-int-params ] bi ;

GENERIC# reg-class-full? 1 ( reg-class abi -- ? )

M: stack-params reg-class-full? 2drop t ;

M: reg-class reg-class-full?
    [ get ] swap '[ _ param-regs length ] bi >= ;

: alloc-stack-param ( rep -- n reg-class rep )
    stack-params get
    [ rep-size cell align stack-params +@ ] dip
    stack-params dup ;

: alloc-fastcall-param ( rep -- n reg-class rep )
    [ [ reg-class-of get ] [ reg-class-of ] [ next-fastcall-param ] tri ] keep ;

:: alloc-parameter ( rep abi -- reg rep )
    rep dup reg-class-of abi reg-class-full?
    [ alloc-stack-param ] [ alloc-fastcall-param ] if
    [ abi param-reg ] dip ;

: reset-fastcall-counts ( -- )
    { int-regs float-regs stack-params } [ 0 swap set ] each ;

: with-param-regs ( quot -- )
    #! In quot you can call alloc-parameter
    [ reset-fastcall-counts call ] with-scope ; inline

:: move-parameters ( params word -- )
    #! Moves values from C stack to registers (if word is
    #! ##load-param-reg) and registers to C stack (if word is
    #! ##save-param-reg).
    0 params alien-parameters flatten-c-types [
        [ params abi>> alloc-parameter word execute( offset reg rep -- ) ]
        [ rep-size cell align + ]
        2bi
    ] each drop ; inline

: parameter-offsets ( types -- offsets )
    0 [ stack-size + ] accumulate nip ;

: prepare-parameters ( parameters -- offsets types indices )
    [ length iota <reversed> ] [ parameter-offsets ] [ ] tri ;

GENERIC: unbox-parameter ( src n c-type -- )

M: c-type unbox-parameter
    [ rep>> ] [ unboxer>> ] bi ##unbox ;

M: long-long-type unbox-parameter
    unboxer>> ##unbox-long-long ;

M: struct-c-type unbox-parameter
    [ ##unbox-large-struct ] [ base-type unbox-parameter ] if-value-struct ;

: unbox-parameters ( offset node -- )
    parameters>> swap
    '[
        prepare-parameters
        [
            [ <ds-loc> ^^peek ] [ _ + ] [ base-type ] tri*
            unbox-parameter
        ] 3each
    ]
    [ length neg ##inc-d ]
    bi ;

: prepare-box-struct ( node -- offset )
    #! Return offset on C stack where to store unboxed
    #! parameters. If the C function is returning a structure,
    #! the first parameter is an implicit target area pointer,
    #! so we need to use a different offset.
    return>> large-struct?
    [ ##prepare-box-struct cell ] [ 0 ] if ;

: objects>registers ( params -- )
    #! Generate code for unboxing a list of C types, then
    #! generate code for moving these parameters to registers on
    #! architectures where parameters are passed in registers.
    [
        [ prepare-box-struct ] keep
        [ unbox-parameters ] keep
        \ ##load-param-reg move-parameters
    ] with-param-regs ;

GENERIC: box-return ( c-type -- dst )

M: c-type box-return
    [ f ] dip [ rep>> ] [ boxer>> ] bi ^^box ;

M: long-long-type box-return
    [ f ] dip boxer>> ^^box-long-long ;

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
        ! Unbox parameters
        dup objects>registers
        ! Call function
        dup alien-invoke-dlsym ##alien-invoke
        ! Box return value
        dup ##cleanup
        box-return*
    ] emit-alien-node ;

M: #alien-indirect emit-node
    [
        D 0 ^^peek -1 ##inc-d ^^unbox-any-c-ptr
        {
            [ drop objects>registers ]
            [ nip ##alien-indirect ]
            [ drop ##cleanup ]
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

M: struct-c-type box-parameter
    [ ^^box-large-struct ] [ base-type box-parameter ] if-value-struct ;

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

: registers>objects ( node -- )
    ! Generate code for boxing input parameters in a callback.
    [
        dup \ ##save-param-reg move-parameters
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
    [ f ] dip [ rep>> ] [ unboxer>> ] bi ##unbox ;

M: long-long-type unbox-return
    [ f ] dip unboxer>> ##unbox-long-long ;

M: struct-c-type unbox-return
    [ ##unbox-small-struct ] [ ##unbox-large-struct ] if-small-struct ;

M: #alien-callback emit-node
    dup params>> xt>> dup
    [
        ##prologue
        [
            [ registers>objects ]
            [ wrap-callback-quot ##alien-callback ]
            [
                alien-return [ ##end-callback ] [
                    [ D 0 ^^peek ] dip
                    ##end-callback
                    base-type unbox-return
                ] if-void
            ] tri
        ] emit-alien-node
        ##epilogue
        ##return
    ] with-cfg-builder ;
