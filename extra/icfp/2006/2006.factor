! Copyright (C) 2007 Gavin Harrison
! See https://factorcode.org/license.txt for BSD license.
USING: arrays combinators endian grouping io io.encodings.binary
io.files kernel math math.functions namespaces sequences vectors ;
IN: icfp.2006

SYMBOL: regs
SYMBOL: arrays
SYMBOL: finger
SYMBOL: open-arrays

: reg-val ( m -- n ) regs get nth ;

: set-reg ( val n -- ) regs get set-nth ;

: arr-val ( index loc -- z )
    arrays get nth nth ;

: set-arr ( val index loc -- )
    arrays get nth set-nth ;

: get-op ( num -- op )
    -28 shift 0b1111 bitand ;

: get-value ( platter -- register )
    0x1ffffff bitand ;

: >32bit ( m -- n ) 0xffffffff bitand ; inline

: get-a ( platter -- register )
    -6 shift 0b111 bitand ; inline

: get-b ( platter -- register )
    -3 shift 0b111 bitand ; inline

: get-c ( platter -- register )
    0b111 bitand ; inline

: get-cb ( platter -- b c ) [ get-c ] keep get-b ;
: get-cba ( platter -- c b a ) [ get-cb ] keep get-a ;
: get-special ( platter -- register )
    -25 shift 0b111 bitand ; inline

: op0 ( opcode -- ? )
    get-cba rot reg-val zero? [
        2drop
    ] [
        [ reg-val ] dip set-reg
    ] if f ;

: binary-op ( quot -- ? )
    [ get-cba ] dip
    swap [ [ [ reg-val ] bi@ swap ] dip call ] dip
    set-reg f ; inline

: op1 ( opcode -- ? )
    [ swap arr-val ] binary-op ;

: op2 ( opcode -- ? )
    get-cba [ [ reg-val ] bi@ ] dip reg-val set-arr f ;

: op3 ( opcode -- ? )
    [ + >32bit ] binary-op ;

: op4 ( opcode -- ? )
    [ * >32bit ] binary-op ;

: op5 ( opcode -- ? )
    [ /i ] binary-op ;

: op6 ( opcode -- ? )
    [ bitand 0xffffffff swap - ] binary-op ;

: new-array ( size location -- )
    [ 0 <array> ] dip arrays get set-nth ;

: ?grow-storage ( -- )
    open-arrays get dup empty? [
        [ arrays get length ] dip push
    ] [
        drop
    ] if ;

: op8 ( opcode -- ? )
    ?grow-storage
    get-cb [ reg-val open-arrays get pop [ new-array ] keep ] dip
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
        { 0 [ op0 ] }
        { 1 [ op1 ] }
        { 2 [ op2 ] }
        { 3 [ op3 ] }
        { 4 [ op4 ] }
        { 5 [ op5 ] }
        { 6 [ op6 ] }
        { 7 [ drop t ] }
        { 8 [ op8 ] }
        { 9 [ op9 ] }
        { 10 [ op10 ] }
        { 11 [ op11 ] }
        { 12 [ op12 ] }
        { 13 [ op13 ] }
    } case ;

: exec-loop ( bool -- )
    [ run-op exec-loop ] unless ;

: load-platters ( path -- )
    binary file-contents 4 group [ be> ] map
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
    "resource:extra/icfp/2006/sandmark.umz" run-prog ;
