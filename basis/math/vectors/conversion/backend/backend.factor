! (c)Joe Groff bsd license
USING: accessors alien.c-types arrays assocs classes combinators
cords fry kernel math math.vectors sequences ;
IN: math.vectors.conversion.backend

: saturate-map-as ( v quot result -- w )
    [ element-type '[ @ _ c-type-clamp ] ] keep map-as ; inline

: (v>float) ( i to-type -- f )
    [ >float ] swap new map-as ;
: (v>integer) ( f to-type -- i )
    [ >integer ] swap new map-as ;
: (vpack-signed) ( a b to-type -- ab )
    [ cord-append [ ] ] dip new saturate-map-as ;
: (vpack-unsigned) ( a b to-type -- ab )
    [ cord-append [ ] ] dip new saturate-map-as ;
: (vunpack-head) ( ab to-type -- a )
    [ dup length 2 /i head-slice ] dip new like ;
: (vunpack-tail) ( ab to-type -- b )
    [ dup length 2 /i tail-slice ] dip new like ;

