! Copyright (C) 2026 Factor contributors.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays kernel locals math sequences sorting vectors ;
IN: compiler.cfg.register-allocation.occupancy

! Each physical register contains disjoint inclusive ranges. Index individual
! ranges, not their convex hulls: a value can live in another value's holes.
! Entries are { start end owner assignment-order }. The order preserves the
! eviction order of the original assignment vectors, even across reinsertion.
TUPLE: register-occupancy entries serial ;

: <register-occupancy> ( -- occupancy )
    V{ } clone 0 register-occupancy boa ;

:: occupancy-lower-bound ( n entries -- i )
    0 :> lo!
    entries length :> hi!
    [ lo hi < ] [
        lo hi + 2 /i :> mid
        mid entries nth second n <
        [ mid 1 + lo! ] [ mid hi! ] if
    ] while lo ;

:: occupy-ranges ( owner ranges occupancy -- )
    occupancy serial>> :> serial
    ranges [| range |
        range first2 owner serial 4array :> entry
        occupancy entries>> :> entries
        range first entries occupancy-lower-bound :> i
        i entries length = [ entry entries push ] [
            occupancy entry i entries insert-nth >>entries drop
        ] if
    ] each
    occupancy serial 1 + >>serial drop ;

:: release-ranges ( owner occupancy -- )
    occupancy [ [ third owner eq? not ] filter! ] change-entries drop ;

:: occupancy-conflicts ( ranges occupancy -- owners )
    occupancy entries>> :> entries
    entries empty? [ { } ] [
        V{ } clone :> hits
        ranges [| range |
            range first entries occupancy-lower-bound :> i!
            [ i entries length < [ i entries nth first range second <= ] [ f ] if ] [
                i entries nth :> entry
                hits [ third entry third eq? ] any? [ entry hits push ] unless
                i 1 + i!
            ] while
        ] each
        hits [ fourth ] sort-by [ third ] map
    ] if ;
