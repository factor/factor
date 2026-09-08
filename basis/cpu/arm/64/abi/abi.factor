! ARM64 homogeneous aggregate layout shared by callers and va_list readers.
USING: accessors alien.arrays alien.c-types arrays classes.struct
combinators combinators.short-circuit cpu.architecture grouping kernel locals
math sequences sorting ;
QUALIFIED: sets
IN: cpu.arm.64.abi

! An ABI member is { byte-offset byte-size representation }.
! Vector lane types and the two 16-bit float formats do not distinguish
! fundamental ABI types. Register transport uses the same bits for each.
: homogeneous-rep ( rep -- rep' )
    {
        { [ dup small-float-rep? ] [ drop half-rep ] }
        { [ dup vector-rep? ] [ drop float-4-rep ] }
        [ ]
    } cond ;

: homogeneous-rep? ( rep -- ? )
    { [ float-rep? ] [ double-rep? ] [ small-float-rep? ] [ vector-rep? ] } 1|| ;

GENERIC: homogeneous-aggregate-members ( type -- members/f )

M: object homogeneous-aggregate-members
    c-type-rep dup homogeneous-rep? [
        homogeneous-rep [ drop 0 ] [ rep-size ] [ ] tri 3array 1array
    ] [ drop f ] if ;

M: string-type homogeneous-aggregate-members drop f ;

:: offset-homogeneous-members ( members offset -- members' )
    members [ first3 [ offset + ] 2dip 3array ] map ;

! Validate each nested composite before merging overlaps. Otherwise an
! unpadded union alternative could hide padding in another alternative.
:: dense-homogeneous-members ( members size -- members/f )
    members sets:members [ first ] sort-by :> unique
    unique empty? [ f ] [
        unique first second :> stride
        unique {
            [ length 4 <= ]
            [ [ third ] map all-equal? ]
            [ [ first ] map dup length <iota> [ stride * ] map = ]
            [ length stride * size = ]
        } 1&& [ unique ] [ f ] if
    ] if ;

M:: array homogeneous-aggregate-members ( type -- members/f )
    type unclip [ array-length ] [ lookup-c-type ] bi* :> ( count element )
    element homogeneous-aggregate-members :> members
    members [
        count <iota> [ members swap element heap-size * offset-homogeneous-members ] map concat
        type heap-size dense-homogeneous-members
    ] [ f ] if ;

M:: struct-c-type homogeneous-aggregate-members ( type -- members/f )
    type fields>> [| field |
        field type>> lookup-c-type homogeneous-aggregate-members
        [ field offset>> offset-homogeneous-members ] [ f ] if*
    ] map :> fields
    fields [ ] all? [ fields concat type heap-size dense-homogeneous-members ] [ f ] if ;
