! Copyright (C) 2014 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: arrays kernel math math.order math.private sequences
sequences.private strings vectors ;

IN: sorting.quick

<PRIVATE

:: quicksort ( seq from to quot: ( obj1 obj2 -- <=> ) -- )
    from to < [
        from to fixnum+fast 2/ seq nth-unsafe :> pivot

        from to [ 2dup <= ] [
            [
                over seq nth-unsafe pivot quot call
                +lt+ eq?
            ] [ [ 1 fixnum+fast ] dip ] while

            [
                dup seq nth-unsafe pivot quot call
                +gt+ eq?
            ] [ 1 fixnum-fast ] while

            2dup <= [
                [ seq exchange-unsafe ]
                [ [ 1 fixnum+fast ] [ 1 fixnum-fast ] bi* ] 2bi
            ] when
        ] while

        [ seq from ] dip quot quicksort
        [ seq ] dip to quot quicksort
    ] when ; inline recursive

: check-array-capacity ( n -- n )
    integer>fixnum-strict dup array-capacity?
    [ "too large" throw ] unless ; inline

PRIVATE>

: sort-with! ( seq quot: ( obj1 obj2 -- <=> ) -- )
    [ 0 over length check-array-capacity 1 - ] dip quicksort ; inline

: inv-sort-with! ( seq quot: ( obj1 obj2 -- <=> ) -- )
    '[ @ invert-comparison ] sort-with! ; inline

: sort-by! ( seq quot: ( elt -- key ) -- )
    [ compare ] curry sort-with! ; inline

: inv-sort-by! ( seq quot: ( elt -- key ) -- )
    [ compare invert-comparison ] curry sort-with! ; inline

GENERIC: sort! ( seq -- )

M: object sort! [ <=> ] sort-with! ;
M: array sort! [ <=> ] sort-with! ;
M: vector sort! [ <=> ] sort-with! ;
M: string sort! [ <=> ] sort-with! ;

GENERIC: inv-sort! ( seq -- )

M: object inv-sort! [ <=> ] inv-sort-with! ;
M: array inv-sort! [ <=> ] inv-sort-with! ;
M: vector inv-sort! [ <=> ] inv-sort-with! ;
M: string inv-sort! [ <=> ] inv-sort-with! ;
