! Copyright (C) 2011 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs bit-arrays classes.tuple
compiler.codegen.relocation cpu.architecture kernel layouts make
math namespaces sequences ;
IN: compiler.codegen.gc-maps

SYMBOLS: return-addresses gc-maps ;

: gc-map-needed? ( gc-map/f -- ? )
    [ tuple-slots [ empty? ] all? not ] ?call ;

: gc-map-here ( gc-map -- )
    dup gc-map-needed? [
        gc-maps get push
        compiled-offset return-addresses get push
    ] [ drop ] if ;

: integers>bits ( seq n -- bit-array )
    <bit-array> [ '[ [ t ] dip _ set-nth ] each ] keep ;

: largest-spill-slot ( seqs -- n )
    concat [ 0 ] [ maximum 1 + ] if-empty ;

: emit-gc-roots ( seqs -- n )
    ! seqs is a sequence of sequences of integers 0..n-1
    dup largest-spill-slot [ '[ _ integers>bits % ] each ] keep ;

: emit-uint ( n -- )
    building get push-uint ;

: emit-uints ( n -- )
    [ emit-uint ] each ;

: gc-root-offsets ( gc-map -- offsets )
    gc-roots>> [ gc-root-offset ] map ;

: emit-gc-info-bitmap ( gc-maps -- spill-count )
    [ gc-root-offsets ] map
    [ emit-gc-roots ] ?{ } make underlying>> % ;

: emit-base-table ( alist longest -- )
    -1 <array> <enumerated> swap assoc-union! seq>> emit-uints ;

: derived-root-offsets ( gc-map -- offsets )
    derived-roots>> [ [ gc-root-offset ] bi@ ] assoc-map ;

: emit-base-tables ( gc-maps -- count )
    [ derived-root-offsets ] map
    dup [ keys ] map largest-spill-slot
    [ '[ _ emit-base-table ] each ] keep ;

: serialize-gc-maps ( -- byte-array )
    [
        return-addresses get empty? [ { } ] [
            gc-maps get [ emit-gc-info-bitmap ] [ emit-base-tables ] bi 2array
        ] if
        return-addresses get emit-uints
        emit-uints
        return-addresses get length emit-uint
    ] B{ } make ;

: emit-gc-maps ( -- )
    serialize-gc-maps [
        length compiled-offset +
        [ data-alignment get align ] keep -
        (align-code)
    ] [ % ] bi ;
