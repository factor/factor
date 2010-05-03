! Copyright (C) 2008, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.complex alien.c-types
alien.libraries alien.private alien.strings arrays
classes.struct combinators compiler.alien
compiler.cfg.instructions compiler.codegen
compiler.codegen.fixup compiler.errors compiler.utilities
cpu.architecture fry kernel layouts libc locals make math
math.order math.parser namespaces quotations sequences strings ;
FROM: compiler.errors => no-such-symbol ;
IN: compiler.codegen.alien

! ##alien-invoke
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

:: alloc-parameter ( parameter abi -- reg rep )
    parameter c-type-rep dup reg-class-of abi reg-class-full?
    [ alloc-stack-param ] [ alloc-fastcall-param ] if
    [ abi param-reg ] dip ;

SYMBOL: (stack-value)
<< void* c-type clone \ (stack-value) define-primitive-type
stack-params \ (stack-value) c-type (>>rep) >>

: ((flatten-type)) ( type to-type -- seq )
    [ stack-size cell align cell /i ] dip c-type <repetition> ; inline

: (flatten-int-type) ( type -- seq )
    void* ((flatten-type)) ;
: (flatten-stack-type) ( type -- seq )
    (stack-value) ((flatten-type)) ;

GENERIC: flatten-value-type ( type -- types )

M: object flatten-value-type 1array ;
M: struct-c-type flatten-value-type (flatten-int-type) ;
M: long-long-type flatten-value-type (flatten-int-type) ;
M: c-type-name flatten-value-type c-type flatten-value-type ;

: flatten-value-types ( params -- params )
    #! Convert value type structs to consecutive void*s.
    [
        0 [
            c-type
            [ parameter-align cell /i void* c-type <repetition> % ] keep
            [ stack-size cell align + ] keep
            flatten-value-type %
        ] reduce drop
    ] { } make ;

: each-parameter ( parameters quot -- )
    [ [ parameter-offsets nip ] keep ] dip 2each ; inline

: reset-fastcall-counts ( -- )
    { int-regs float-regs stack-params } [ 0 swap set ] each ;

: with-param-regs ( quot -- )
    #! In quot you can call alloc-parameter
    [ reset-fastcall-counts call ] with-scope ; inline

: move-parameters ( node word -- )
    #! Moves values from C stack to registers (if word is
    #! %load-param-reg) and registers to C stack (if word is
    #! %save-param-reg).
    [ [ alien-parameters flatten-value-types ] [ abi>> ] bi ]
    [ '[ _ alloc-parameter _ execute ] ]
    bi* each-parameter ; inline

: reverse-each-parameter ( parameters quot -- )
    [ [ parameter-offsets nip ] keep ] dip 2reverse-each ; inline

: prepare-unbox-parameters ( parameters -- offsets types indices )
    [ parameter-offsets nip ] [ ] [ length iota <reversed> ] tri ;

: unbox-parameters ( offset node -- )
    parameters>> swap
    '[ prepare-unbox-parameters [ %pop-stack [ _ + ] dip unbox-parameter ] 3each ]
    [ length neg %inc-d ]
    bi ;

: prepare-box-struct ( node -- offset )
    #! Return offset on C stack where to store unboxed
    #! parameters. If the C function is returning a structure,
    #! the first parameter is an implicit target area pointer,
    #! so we need to use a different offset.
    return>> large-struct?
    [ %prepare-box-struct cell ] [ 0 ] if ;

: objects>registers ( params -- )
    #! Generate code for unboxing a list of C types, then
    #! generate code for moving these parameters to registers on
    #! architectures where parameters are passed in registers.
    [
        [ prepare-box-struct ] keep
        [ unbox-parameters ] keep
        \ %load-param-reg move-parameters
    ] with-param-regs ;

: box-return* ( node -- )
    return>> [ ] [ box-return %push-stack ] if-void ;

GENERIC# dlsym-valid? 1 ( symbols dll -- ? )

M: string dlsym-valid? dlsym ;

M: array dlsym-valid? '[ _ dlsym ] any? ;

: check-dlsym ( symbols dll -- )
    dup dll-valid? [
        dupd dlsym-valid?
        [ drop ] [ compiling-word get no-such-symbol ] if
    ] [
        dll-path compiling-word get no-such-library drop
    ] if ;

: decorated-symbol ( params -- symbols )
    [ function>> ] [ parameters>> parameter-offsets drop number>string ] bi
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

M: ##alien-invoke generate-insn
    params>>
    ! Unbox parameters
    dup objects>registers
    %prepare-var-args
    ! Call function
    dup alien-invoke-dlsym %alien-invoke
    ! Box return value
    dup %cleanup
    box-return* ;

M: ##alien-assembly generate-insn
    params>>
    ! Unbox parameters
    dup objects>registers
    %prepare-var-args
    ! Generate assembly
    dup quot>> call( -- )
    ! Box return value
    box-return* ;

! ##alien-indirect
M: ##alien-indirect generate-insn
    params>>
    ! Save alien at top of stack to temporary storage
    %prepare-alien-indirect
    ! Unbox parameters
    dup objects>registers
    %prepare-var-args
    ! Call alien in temporary storage
    %alien-indirect
    ! Box return value
    dup %cleanup
    box-return* ;

! ##alien-callback
: box-parameters ( params -- )
    alien-parameters [ box-parameter %push-context-stack ] each-parameter ;

: registers>objects ( node -- )
    ! Generate code for boxing input parameters in a callback.
    [
        dup \ %save-param-reg move-parameters
        %begin-callback
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

M: ##alien-callback generate-insn
    params>>
    [ registers>objects ]
    [ wrap-callback-quot %alien-callback ]
    [ alien-return [ %end-callback ] [ %end-callback-value ] if-void ] tri ;
