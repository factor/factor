! (c)Joe Groff bsd license
USING: accessors alien.c-types arrays assocs classes combinators
combinators.short-circuit cords fry kernel locals math
math.vectors math.vectors.conversion.backend sequences ;
FROM: alien.c-types => char uchar short ushort int uint longlong ulonglong float double ;
IN: math.vectors.conversion

ERROR: bad-vconvert from-type to-type ;
ERROR: bad-vconvert-input value expected-type ;

<PRIVATE

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

:: check-vpack ( from-element to-element from-type to-type steps -- )
    {
        [ steps 1 = not ]
        [ from-element to-element [ float-type? ] bi@ xor ]
        [ from-element unsigned-type? to-element unsigned-type? not and ]
    } 0|| [ from-type to-type bad-vconvert ] when ;

:: [[vpack-unsigned]] ( from-type to-type -- quot )
    [ [ from-type check-vconvert-type ] bi@ to-type (vpack-unsigned) ] ;

:: [[vpack-signed]] ( from-type to-type -- quot )
    [ [ from-type check-vconvert-type ] bi@ to-type (vpack-signed) ] ;

:: [vpack] ( from-element to-element from-size to-size from-type to-type -- quot )
    from-size to-size /i log2 :> steps

    from-element to-element from-type to-type steps check-vpack

    from-type to-type to-element unsigned-type?
    [ [[vpack-unsigned]] ] [ [[vpack-signed]] ] if ;

:: check-vunpack ( from-element to-element from-type to-type steps -- )
    {
        [ steps 1 = not ]
        [ from-element to-element [ float-type? ] bi@ xor ]
        [ from-element unsigned-type? not to-element unsigned-type? and ]
    } 0|| [ from-type to-type bad-vconvert ] when ;

:: [[vunpack]] ( from-type to-type -- quot )
    [
        from-type check-vconvert-type
        [ to-type (vunpack-head) ] [ to-type (vunpack-tail) ] bi
    ] ;

:: [vunpack] ( from-element to-element from-size to-size from-type to-type -- quot )
    to-size from-size /i log2 :> steps
    from-element to-element from-type to-type steps check-vunpack
    from-type to-type [[vunpack]] ; 

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

