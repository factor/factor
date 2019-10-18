USING: kernel alien sequences ;
IN: alien-contrib

: float-array>array ( byte-array n -- array )
    [ swap float-nth ] map-with ;

: uint-array>array ( byte-array n -- array )
    [ swap uint-nth ] map-with ;

: >void*-array 
    [ length "void*" <c-array> ] keep
    dup length [ pick set-void*-nth ] 2each ;

PROVIDE: libs/alien ;
