USING: locals sequences kernel math ;
IN: sorting.insertion

<PRIVATE
:: insert ( ... seq quot: ( ... elt -- ... elt' ) n -- ... )
    n zero? [
        n n 1 - [ seq nth quot call ] bi@ >= [
            n n 1 - seq exchange
            seq quot n 1 - insert
        ] unless
    ] unless ; inline recursive
PRIVATE>

: insertion-sort ( ... seq quot: ( ... elt -- ... elt' ) -- ... )
    ! quot is a transformation on elements
    over length [ insert ] with with each-integer ; inline
