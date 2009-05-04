! (c)2009 Joe Groff bsd license
USING: accessors arrays kernel locals math sequences ;
IN: sequences.product

TUPLE: product-sequence { sequences array read-only } { lengths array read-only } ;

: <product-sequence> ( sequences -- product-sequence )
    >array dup [ length ] map product-sequence boa ;

INSTANCE: product-sequence sequence

M: product-sequence length lengths>> product ;

<PRIVATE

: ns ( n lengths -- ns )
    [ V{ } clone ] 2dip [ /mod swap [ over push ] dip ] each drop ;

: nths ( ns seqs -- nths )
    [ nth ] { } 2map-as ;

: product@ ( n product-sequence -- ns seqs )
    [ lengths>> ns ] [ nip sequences>> ] 2bi ;

:: (carry-n) ( ns lengths i -- )
    ns length i 1+ = [
        i ns nth i lengths nth = [
            0 i ns set-nth
            i 1+ ns [ 1+ ] change-nth
            ns lengths i 1+ (carry-n)
        ] when
    ] unless ;

: carry-ns ( ns lengths -- )
    0 (carry-n) ;
    
: product-iter ( ns lengths -- )
    [ 0 over [ 1+ ] change-nth ] dip carry-ns ;

: start-product-iter ( sequence-product -- ns lengths )
    [ [ drop 0 ] map ] [ [ length ] map ] bi ;

: end-product-iter? ( ns lengths -- ? )
    [ 1 tail* first ] bi@ = ;

PRIVATE>

M: product-sequence nth 
    product@ nths ;

:: product-each ( sequences quot -- )
    sequences start-product-iter :> lengths :> ns
    [ ns lengths end-product-iter? ]
    [ ns sequences nths quot call ns lengths product-iter ] until ; inline

:: product-map ( sequences quot -- sequence )
    0 :> i!
    sequences [ length ] [ * ] map-reduce sequences
    [| result |
        sequences [ quot call i result set-nth i 1+ i! ] product-each
        result
    ] new-like ; inline

