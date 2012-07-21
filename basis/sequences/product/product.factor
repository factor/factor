! (c)2009 Joe Groff bsd license
USING: accessors arrays assocs kernel locals math sequences ;
FROM: sequences => change-nth ;
IN: sequences.product

TUPLE: product-sequence { sequences array read-only } { lengths array read-only } ;

: <product-sequence> ( sequences -- product-sequence )
    >array dup [ length ] map product-sequence boa ;

INSTANCE: product-sequence sequence

M: product-sequence length lengths>> product ;

<PRIVATE

: ns ( n lengths -- ns )
    [ /mod ] map nip ;

: nths ( ns seqs -- nths )
    [ nth ] { } 2map-as ;

: product@ ( n product-sequence -- ns seqs )
    [ lengths>> ns ] [ nip sequences>> ] 2bi ;

:: (carry-n) ( ns lengths i -- )
    ns length i 1 + = [
        i ns nth i lengths nth = [
            0 i ns set-nth
            i 1 + ns [ 1 + ] change-nth
            ns lengths i 1 + (carry-n)
        ] when
    ] unless ;

: carry-ns ( ns lengths -- )
    0 (carry-n) ;

: product-iter ( ns lengths -- )
    [ 0 over [ 1 + ] change-nth ] dip carry-ns ;

: start-product-iter ( sequences -- ns lengths )
    [ length 0 <array> ] [ [ length ] map ] bi ;

: end-product-iter? ( ns lengths -- ? )
    [ last ] same? ;

PRIVATE>

M: product-sequence nth
    product@ nths ;

:: product-each ( ... sequences quot: ( ... seq -- ... ) -- ... )
    sequences start-product-iter :> ( ns lengths )
    lengths [ 0 = ] any? [
        [ ns lengths end-product-iter? ]
        [ ns sequences nths quot call ns lengths product-iter ] until
    ] unless ; inline

:: product-map-as ( ... sequences quot: ( ... seq -- ... value ) exemplar -- ... sequence )
    0 :> i!
    sequences [ length ] [ * ] map-reduce exemplar
    [| result |
        sequences [ quot call i result set-nth i 1 + i! ] product-each
        result
    ] new-like ; inline

: product-map ( ... sequences quot: ( ... seq -- ... value ) -- ... sequence )
    over product-map-as ; inline

:: product-map>assoc ( ... sequences quot: ( ... seq -- ... key value ) exemplar -- ... assoc )
    0 :> i!
    sequences [ length ] [ * ] map-reduce { }
    [| result |
        sequences [ quot call 2array i result set-nth i 1 + i! ] product-each
        result
    ] new-like exemplar assoc-like ; inline
