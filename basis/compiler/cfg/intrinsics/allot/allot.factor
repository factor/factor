! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays byte-arrays compiler.cfg.builder.blocks
compiler.cfg.hats compiler.cfg.instructions
compiler.cfg.registers compiler.cfg.stacks compiler.constants
compiler.tree.propagation.info cpu.architecture kernel layouts
math math.order sequences ;
IN: compiler.cfg.intrinsics.allot

: ##set-slots, ( regs obj class -- )
    '[ _ swap 1 + _ type-number ##set-slot-imm, ] each-index ;

: emit-simple-allot ( node -- )
    [ in-d>> length ] [ node-output-infos first class>> ] bi
    [ drop ds-loc load-vregs ] [ [ 1 + cells ] dip ^^allot ] [ nip ] 2tri
    [ ##set-slots, ] [ [ drop ] [ ds-push ] [ drop ] tri* ] 3bi ;

: tuple-slot-regs ( layout -- vregs )
    [ second ds-loc load-vregs ] [ ^^load-literal ] bi prefix ;

: ^^allot-tuple ( n -- dst )
    2 + cells tuple ^^allot ;

: emit-<tuple-boa> ( block #call -- block' )
    dup node-input-infos last literal>>
    dup array? [
        nip
        ds-drop
        [ tuple-slot-regs ] [ second ^^allot-tuple ] bi
        [ tuple ##set-slots, ] [ ds-push drop ] 2bi
    ] [ drop emit-primitive ] if ;

: store-length ( len reg class -- )
    [ [ ^^load-literal ] dip 1 ] dip type-number ##set-slot-imm, ;

:: store-initial-element ( len reg elt class -- )
    len [ [ elt reg ] dip 2 + class type-number ##set-slot-imm, ] each-integer ;

: expand-<array>? ( obj -- ? )
    dup integer? [ 0 8 between? ] [ drop f ] if ;

: ^^allot-array ( n -- dst )
    2 + cells array ^^allot ;

:: emit-<array> ( block node -- block' )
    node node-input-infos first literal>> :> len
    len expand-<array>? [
        ds-pop :> elt
        len ^^allot-array :> reg
        ds-drop
        len reg array store-length
        len reg elt array store-initial-element
        reg ds-push block
    ] [ block node emit-primitive ] if ;

: expand-(byte-array)? ( obj -- ? )
    dup integer? [ 0 1024 between? ] [ drop f ] if ;

: expand-<byte-array>? ( obj -- ? )
    dup integer? [ 0 32 between? ] [ drop f ] if ;

: bytes>cells ( m -- n ) cell align cell /i ;

: ^^allot-byte-array ( len -- dst )
    dup 16 + byte-array ^^allot [ byte-array store-length ] keep ;

: emit-allot-byte-array ( len -- dst )
    ds-drop ^^allot-byte-array dup ds-push ;

: emit-(byte-array) ( block node -- block' )
    dup node-input-infos first literal>> dup expand-(byte-array)? [
        nip emit-allot-byte-array drop
    ] [ drop emit-primitive ] if ;

:: zero-byte-array ( len reg -- )
    0 ^^load-literal :> elt
    reg ^^tagged>integer :> reg
    len cell align cell /i <iota> [
        [ elt reg ] dip cells byte-array-offset + int-rep f ##store-memory-imm,
    ] each ;

:: emit-<byte-array> ( block #call -- block' )
    #call node-input-infos first literal>> dup expand-<byte-array>? [
        :> len
        len emit-allot-byte-array :> reg
        len reg zero-byte-array block
    ] [ drop block #call emit-primitive ] if ;
