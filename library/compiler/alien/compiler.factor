! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: alien
USING: arrays compiler generic hashtables kernel
kernel-internals math namespaces sequences words
inference ;

: parameter-size c-size cell align ;

: parameter-sizes ( types -- offsets )
    #! Compute stack frame locations.
    0 [ parameter-size + ] accumulate nip ;

: stack-space ( parameters -- n )
    0 [ parameter-size + ] reduce ;

: reg-class-full? ( class -- ? )
    dup class get swap fastcall-regs length >= ;

: spill-param ( reg-class -- n reg-class )
    reg-size stack-params dup get -rot +@ T{ stack-params } ;

: fastcall-param ( reg-class -- n reg-class )
    [ dup class get swap inc-reg-class ] keep ;

: alloc-parameter ( parameter -- reg reg-class )
    c-type c-type-reg-class dup reg-class-full?
    [ spill-param ] [ fastcall-param ] if
    [ fastcall-regs nth ] keep ;

: flatten-value-types ( params -- params )
    #! Convert value type structs to consecutive void*s.
    [
        dup c-struct?
        [ c-size cell / "void*" <array> ] [ 1array ] if
    ] map concat ;

: each-parameter ( parameters quot -- )
    >r [ parameter-sizes ] keep r> 2each ; inline

: reverse-each-parameter ( parameters quot -- )
    >r [ parameter-sizes ] keep
    [ <reversed> ] 2apply r> 2each ; inline

: reset-freg-counts ( -- )
    0 { int-regs float-regs stack-params } [ set ] each-with ;

: move-parameters ( params word -- )
    #! Moves values from C stack to registers (if word is
    #! %stack>freg) and registers to C stack (if word is
    #! %freg>stack).
    swap [
        flatten-value-types
        reset-freg-counts
        [ pick >r alloc-parameter r> execute ] each-parameter
        drop
    ] with-scope ; inline

: if-void ( type true false -- )
    pick "void" = [ drop nip call ] [ nip call ] if ; inline

: make-prep-quot ( parameters -- )
    dup empty? [
        drop
    ] [
        unclip c-type c-type-prep %
        \ >r , make-prep-quot \ r> ,
    ] if ;

: prep-alien-parameters ( parameters -- quot )
    [ <reversed> make-prep-quot ] [ ] make infer-quot ;
