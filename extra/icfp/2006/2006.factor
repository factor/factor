! Copyright (C) 2007 Gavin Harrison
! See http://factorcode.org/license.txt for BSD license.

USING: kernel math sequences kernel.private namespaces arrays
io io.files splitting io.binary math.functions vectors
quotations combinators.private ;
IN: universal-machine

SYMBOL: regs
SYMBOL: arrays
SYMBOL: finger
SYMBOL: open-arrays

: call-nth ( n array -- )
    >r >fixnum r> 2dup nth quotation?
    [ dispatch ] [ "Not a quotation" throw ] if ; inline

: reg-val ( m -- n ) regs get nth ;

: set-reg ( val n -- ) regs get set-nth ;

: arr-val ( index loc -- z )
    arrays get nth nth ;

: set-arr ( val index loc -- )
    arrays get nth set-nth ;

: get-op ( num -- op )
    -28 shift BIN: 1111 bitand ;

: get-value ( platter -- register )
    HEX: 1ffffff bitand ;

: >32bit ( m -- n ) HEX: ffffffff bitand ; inline

: get-a ( platter -- register )
    -6 shift BIN: 111 bitand ; inline

: get-b ( platter -- register )
    -3 shift BIN: 111 bitand ; inline

: get-c ( platter -- register )
    BIN: 111 bitand ; inline

: get-cb ( platter -- b c ) [ get-c ] keep get-b ;
: get-cba ( platter -- c b a ) [ get-cb ] keep get-a ;
: get-special ( platter -- register )
    -25 shift BIN: 111 bitand ; inline

: op0 ( opcode -- ? )
    get-cba rot reg-val zero? [
        2drop
    ] [
        >r reg-val r> set-reg
    ] if f ;

: binary-op ( quot -- ? )
    >r get-cba r>
    swap >r >r [ reg-val ] 2apply swap r> call r>
    set-reg f ; inline
    
: op1 ( opcode -- ? )
    [ swap arr-val ] binary-op ;

: op2 ( opcode -- ? )
    get-cba >r [ reg-val ] 2apply r> reg-val set-arr f ;

: op3 ( opcode -- ? )
    [ + >32bit ] binary-op ;

: op4 ( opcode -- ? )
    [ * >32bit ] binary-op ;

: op5 ( opcode -- ? )
    [ /i ] binary-op ;

: op6 ( opcode -- ? )
    [ bitand HEX: ffffffff swap - ] binary-op ;

: new-array ( size location -- )
    >r 0 <array> r> arrays get set-nth ;

: ?grow-storage ( -- )
    open-arrays get dup empty? [
        >r arrays get length r> push
    ] [
        drop
    ] if ;

: op8 ( opcode -- ? )
    ?grow-storage
    get-cb >r reg-val open-arrays get pop [ new-array ] keep r> 
    set-reg f ;

: op9 ( opcode -- ? )
    get-c reg-val dup open-arrays get push
    f swap arrays get set-nth f ;

: op10 ( opcode -- ? )
    get-c reg-val write1 flush f ;

: op11 ( opcode -- ? )
    drop f ;

: op12 ( opcode -- ? )
    get-cb reg-val dup zero? [
        drop
    ] [
        arrays get [ nth clone 0 ] keep set-nth
    ] if reg-val finger set f ;

: op13 ( opcode -- ? )
    [ get-value ] keep get-special set-reg f ;
    
: advance ( -- val opcode )
    finger get arrays get first nth
    finger inc dup get-op ;

: run-op ( -- bool )
    advance
    {
        [ op0 ] [ op1 ] [ op2 ] [ op3 ]
        [ op4 ] [ op5 ] [ op6 ] [ drop t ]
        [ op8 ] [ op9 ] [ op10 ] [ op11 ]
        [ op12 ] [ op13 ]
    } call-nth ;

: exec-loop ( bool -- )
    [ run-op exec-loop ] unless ;

: load-platters ( path -- )
    <file-reader> contents 4 group [ be> ] map
    0 arrays get set-nth ;

: init ( path -- )
    8 0 <array> regs set
    2 16 ^ <vector> arrays set
    0 finger set
    V{ } clone open-arrays set
    load-platters ;

: run-prog ( path -- )
    init f exec-loop ;

: run-sand ( -- )
    "extra/icfp/2006/sandmark.umz" resource-path run-prog ;
