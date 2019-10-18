! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: arrays generator generic hashtables kernel
kernel-internals math namespaces sequences words
inference ;

! Common protocol for alien-invoke/alien-callback/alien-indirect
GENERIC: alien-node-parameters ( node -- seq )
GENERIC: alien-node-return ( node -- ctype )
GENERIC: alien-node-abi ( node -- str )

: large-struct? ( ctype -- ? )
    dup c-struct? [
        heap-size struct-small-enough? not
    ] [
        drop f
    ] if ;

: alien-node-parameters* ( node -- seq )
    dup alien-node-parameters
    swap alien-node-return large-struct? [ "void*" add* ] when ;

: alien-node-return* ( node -- ctype )
    alien-node-return dup large-struct? [ drop "void" ] when ;

: parameter-size stack-size cell align ;

: parameter-sizes ( types -- offsets )
    #! Compute stack frame locations.
    0 [ parameter-size + ] accumulate nip ;

: return-size ( ctype -- n )
    #! Amount of space we reserve for a return value.
    dup large-struct? [ heap-size ] [ drop 0 ] if ;

: alien-stack-frame ( node -- n )
    alien-node-parameters* 0 [ parameter-size + ] reduce ;

: alien-invoke-frame ( node -- n )
    #! One cell is temporary storage, temp@
    dup alien-node-return return-size
    swap alien-stack-frame +
    cell + ;

: reg-class-full? ( class -- ? )
    dup class get swap param-regs length >= ;

: spill-param ( reg-class -- n reg-class )
    reg-size stack-params dup get -rot +@ T{ stack-params } ;

: fastcall-param ( reg-class -- n reg-class )
    [ dup class get swap inc-reg-class ] keep ;

: alloc-parameter ( parameter -- reg reg-class )
    c-type c-type-reg-class dup reg-class-full?
    [ spill-param ] [ fastcall-param ] if
    [ param-reg ] keep ;

: flatten-value-types ( params -- params )
    #! Convert value type structs to consecutive void*s.
    [
        dup c-struct?
        [ stack-size cell / "void*" <array> ] [ 1array ] if
    ] map concat ;

: each-parameter ( parameters quot -- )
    >r [ parameter-sizes ] keep r> 2each ; inline

: reverse-each-parameter ( parameters quot -- )
    >r [ parameter-sizes ] keep
    [ <reversed> ] 2apply r> 2each ; inline

: reset-freg-counts ( -- )
    0 { int-regs float-regs stack-params } [ set ] each-with ;

: with-param-regs ( quot -- )
    #! In quot you can call alloc-parameter
    [ reset-freg-counts call ] with-scope ; inline

: move-parameters ( node word -- )
    #! Moves values from C stack to registers (if word is
    #! %load-param-reg) and registers to C stack (if word is
    #! %save-param-reg).
    swap
    alien-node-parameters*
    flatten-value-types
    [ pick >r alloc-parameter r> execute ] each-parameter
    drop ; inline

: if-void ( type true false -- )
    pick "void" = [ drop nip call ] [ nip call ] if ; inline

: alien-invoke-stack ( node extra -- )
    over alien-node-parameters length + over consume-values
    dup alien-node-return "void" = 0 1 ? swap produce-values ;

: (make-prep-quot) ( parameters -- )
    dup empty? [
        drop
    ] [
        unclip c-type c-type-prep %
        \ >r , (make-prep-quot) \ r> ,
    ] if ;

: make-prep-quot ( node -- quot )
    alien-node-parameters
    [ <reversed> (make-prep-quot) ] [ ] make ;

: unbox-parameters ( offset node -- )
    alien-node-parameters [
        %prepare-unbox >r over + r> unbox-parameter
    ] reverse-each-parameter drop ;

: %before-alien
    #! Save Factor stack pointers in case the C code calls a
    #! callback which does a GC, which must reliably trace
    #! all roots.
    "save_stacks" f %alien-invoke ;

: prepare-box-struct ( node -- offset )
    #! Return offset on C stack where to store unboxed
    #! parameters. If the C function is returning a structure,
    #! the first parameter is an implicit target area pointer,
    #! so we need to use a different offset.
    alien-node-return dup large-struct?
    [ heap-size %prepare-box-struct cell ] [ drop 0 ] if ;

: objects>registers ( node -- )
    #! Generate code for unboxing a list of C types, then
    #! generate code for moving these parameters to register on
    #! architectures where parameters are passed in registers.
    [
        [ prepare-box-struct ] keep
        [ unbox-parameters ] keep
        %before-alien
        \ %load-param-reg move-parameters
    ] with-param-regs ;

: box-return* ( node -- )
    alien-node-return [ ] [ box-return ] if-void ;
