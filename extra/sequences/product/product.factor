USING: accessors arrays kernel math sequences ;
IN: sequences.product

TUPLE: product-sequence { sequences array read-only } { lengths array read-only } ;

: <product-sequence> ( sequences -- product-sequence )
    >array dup [ length ] map product-sequence boa ;

INSTANCE: product-sequence sequence

M: product-sequence length lengths>> product ;

: ns ( n lengths -- ns )
    [ V{ } clone ] 2dip [ /mod swap [ over push ] dip ] each drop ;

: product@ ( n product-sequence -- ns seqs )
    [ lengths>> ns ] [ nip sequences>> ] 2bi ;

M: product-sequence nth 
    product@ [ nth ] { } 2map-as ;

M: product-sequence set-nth
    immutable ;

: product-map ( sequences quot -- sequence )
    [ <product-sequence> ] dip map ; inline
: product-each ( sequences quot -- )
    [ <product-sequence> ] dip each ; inline
