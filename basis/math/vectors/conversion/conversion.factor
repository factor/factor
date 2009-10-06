! (c)Joe Groff bsd license
USING: accessors alien.c-types arrays assocs classes combinators
combinators.short-circuit cords fry kernel locals math
math.vectors sequences ;
FROM: alien.c-types => char uchar short ushort int uint longlong ulonglong float double ;
IN: math.vectors.conversion

ERROR: bad-vconvert from-type to-type ;
ERROR: bad-vconvert-input value expected-type ;

<PRIVATE

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

: float-type? ( c-type -- ? )
    { float double } memq? ;
: unsigned-type? ( c-type -- ? )
    { uchar ushort uint ulonglong } memq? ;

: check-vconvert-type ( value expected-type -- value )
    2dup instance? [ drop ] [ bad-vconvert-input ] if ; inline

:: [vconvert] ( from-element to-element from-size to-size from-type to-type -- quot )
    {
        {
            [ from-element to-element eq? ]
            [ [ ] ]
        }
        {
            [ from-element to-element [ float-type? not ] both? ]
            [ [ underlying>> to-type boa ] ]
        }
        {
            [ from-element float-type? ]
            [ [ to-type (v>integer) ] ]
        }
        {
            [ to-element   float-type? ]
            [ [ to-type (v>float)   ] ]
        }
    } cond
    [ from-type check-vconvert-type ] prepose ;

:: [vpack] ( from-element to-element from-size to-size from-type to-type -- quot )
    from-size to-size /i log2 :> steps

    {
        [ steps 1 = not ]
        [ from-element to-element [ float-type? ] bi@ xor ]
        [ from-element unsigned-type? to-element unsigned-type? not and ]
    } 0|| [ from-type to-type bad-vconvert ] when

    to-element unsigned-type? [ to-type (vpack-unsigned) ] [ to-type (vpack-signed) ] ?
    [ [ from-type check-vconvert-type ] bi@ ] prepose ;

:: [vunpack] ( from-element to-element from-size to-size from-type to-type -- quot )
    to-size from-size /i log2 :> steps

    {
        [ steps 1 = not ]
        [ from-element to-element [ float-type? ] bi@ xor ]
        [ from-element unsigned-type? not to-element unsigned-type? and ]
    } 0|| [ from-type to-type bad-vconvert ] when

    [
        from-type check-vconvert-type
        [ to-type (vunpack-head) ] [ to-type (vunpack-tail) ] bi
    ] ;

PRIVATE>

MACRO:: vconvert ( from-type to-type -- )
    from-type new [ element-type ] [ byte-length ] bi :> from-length :> from-element
    to-type   new [ element-type ] [ byte-length ] bi :> to-length   :> to-element
    from-element heap-size :> from-size
    to-element   heap-size :> to-size   

    from-length to-length = [ from-type to-type bad-vconvert ] unless

    from-element to-element from-size to-size from-type to-type {
        { [ from-size to-size < ] [ [vunpack] ] }
        { [ from-size to-size = ] [ [vconvert] ] }
        { [ from-size to-size > ] [ [vpack] ] }
    } cond ;

