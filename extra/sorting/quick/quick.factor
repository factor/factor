! Copyright (C) 2014 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators kernel locals math math.order sequences
sequences.private ;

IN: sorting.quick

<PRIVATE

:: (quicksort) ( seq from to -- )
    from to < [
        from to + 2/ seq nth-unsafe :> pivot

        from to [ 2dup <= ] [
            [ over seq nth-unsafe pivot before? ] [ [ 1 + ] dip ] while
            [ dup  seq nth-unsafe pivot after? ] [ 1 - ] while
            2dup <= [
                [ seq exchange-unsafe ]
                [ [ 1 + ] [ 1 - ] bi* ] 2bi
            ] when
        ] while

        [ seq from ] dip (quicksort)
        [ seq ] dip to (quicksort)

    ] when ; inline recursive

PRIVATE>

: quicksort ( seq -- )
    0 over length 1 - (quicksort) ;
