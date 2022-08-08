USING: kernel locals math sequences sequences.private ;
IN: sorting.insertion

<PRIVATE

:: insert ( ... seq quot: ( ... elt -- ... elt' ) n -- ... )
    n zero? [
        n n 1 - [ seq nth-unsafe ] bi@
        2dup [ quot call ] bi@ >= [ 2drop ] [
            n 1 - n [ seq set-nth-unsafe ] bi-curry@ bi*
            seq quot n 1 - insert
        ] if
    ] unless ; inline recursive

PRIVATE>

: insertion-sort ( ... seq quot: ( ... elt -- ... elt' ) -- ... )
    ! quot is a transformation on elements
    over length [ insert ] 2with 1 -rot each-integer-from ; inline
