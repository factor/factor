! Copyright (C) 2014 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: combinators kernel locals math math.order sequences
sequences.private ;

IN: sorting.quick

<PRIVATE

:: (quicksort) ( seq from to -- )
    from to < [
        from to + 2/ :> p
        from :> l!
        to :> r!

        p seq nth-unsafe :> p-nth

        [ l r <= ] [
            [ l seq nth-unsafe p-nth before? ] [ l 1 + l! ] while
            [ r seq nth-unsafe p-nth after? ] [ r 1 - r! ] while
            l r <= [
                l r seq exchange-unsafe
                l 1 + l!
                r 1 - r!
            ] when
        ] while

        seq from r (quicksort)
        seq l to (quicksort)

    ] when ; inline recursive

PRIVATE>

: quicksort ( seq -- )
    0 over length 1 - (quicksort) ;
