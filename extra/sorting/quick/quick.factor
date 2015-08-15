! Copyright (C) 2014 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays combinators kernel locals math math.order
sequences sequences.private strings vectors ;

IN: sorting.quick

<PRIVATE

:: quicksort ( seq from to quot: ( obj1 obj2 -- <=> ) -- )
    from to < [
        from to + 2/ seq nth-unsafe :> pivot

        from to [ 2dup <= ] [
            [
                over seq nth-unsafe pivot quot call
                +lt+ eq?
            ] [ [ 1 + ] dip ] while

            [
                dup seq nth-unsafe pivot quot call
                +gt+ eq?
            ] [ 1 - ] while

            2dup <= [
                [ seq exchange-unsafe ]
                [ [ 1 + ] [ 1 - ] bi* ] 2bi
            ] when
        ] while

        [ seq from ] dip quot quicksort
        [ seq ] dip to quot quicksort
    ] when ; inline recursive

PRIVATE>

: sort! ( seq quot: ( obj1 obj2 -- <=> ) -- )
    [ 0 over length 1 - ] dip quicksort ; inline

: sort-with! ( seq quot: ( elt -- key ) -- )
    [ compare ] curry sort! ; inline

: inv-sort-with! ( seq quot: ( elt -- key ) -- )
    [ compare invert-comparison ] curry sort! ; inline

GENERIC: natural-sort! ( seq -- )

M: object natural-sort!  [ <=> ] sort! ;
M: array natural-sort! [ <=> ] sort! ;
M: vector natural-sort! [ <=> ] sort! ;
M: string natural-sort! [ <=> ] sort! ;
