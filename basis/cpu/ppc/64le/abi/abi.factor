! ELFv2 homogeneous floating-point aggregates contain at most eight members.
USING: accessors alien.arrays alien.c-types arrays classes.struct
combinators combinators.short-circuit cpu.architecture grouping kernel locals
math sequences sorting ;
QUALIFIED: sets
IN: cpu.ppc.64le.abi

! An ABI member is { byte-offset byte-size representation }.
: ppc64le-hfa-rep? ( rep -- ? )
    { [ float-rep? ] [ double-rep? ] } 1|| ;

GENERIC: ppc64le-hfa-members ( type -- members/f )

M: object ppc64le-hfa-members
    c-type-rep dup ppc64le-hfa-rep? [
        [ drop 0 ] [ rep-size ] [ ] tri 3array 1array
    ] [ drop f ] if ;

M: string-type ppc64le-hfa-members drop f ;

:: ppc64le-offset-hfa-members ( members offset -- members' )
    members [ first3 [ offset + ] 2dip 3array ] map ;

! Validate each nested composite before merging overlaps. Otherwise an
! unpadded union alternative could hide padding in another alternative.
:: ppc64le-dense-hfa-members ( members size -- members/f )
    members sets:members [ first ] sort-by :> unique
    unique empty? [ f ] [
        unique first second :> stride
        unique {
            [ length 8 <= ]
            [ [ third ] map all-equal? ]
            [ [ first ] map dup length <iota> [ stride * ] map = ]
            [ length stride * size = ]
        } 1&& [ unique ] [ f ] if
    ] if ;

M:: array ppc64le-hfa-members ( type -- members/f )
    type unclip [ array-length ] [ lookup-c-type ] bi* :> ( count element )
    element ppc64le-hfa-members :> members
    members [
        count <iota> [ members swap element heap-size * ppc64le-offset-hfa-members ] map concat
        type heap-size ppc64le-dense-hfa-members
    ] [ f ] if ;

M:: struct-c-type ppc64le-hfa-members ( type -- members/f )
    type fields>> [| field |
        field type>> lookup-c-type ppc64le-hfa-members
        [ field offset>> ppc64le-offset-hfa-members ] [ f ] if*
    ] map :> fields
    fields [ ] all? [ fields concat type heap-size ppc64le-dense-hfa-members ] [ f ] if ;
