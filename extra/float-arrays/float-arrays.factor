! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel kernel.private alien.accessors sequences
sequences.private math math.private byte-arrays accessors
alien.c-types parser prettyprint.backend ;
IN: float-arrays

TUPLE: float-array
{ length array-capacity read-only }
{ underlying byte-array read-only } ;

<PRIVATE

: floats>bytes 8 * ; inline

: float-array@ underlying>> swap >fixnum floats>bytes ; inline

PRIVATE>

: <float-array> ( n -- float-array )
    dup floats>bytes <byte-array> float-array boa ; inline

M: float-array clone
    [ length>> ] [ underlying>> clone ] bi float-array boa ;

M: float-array length length>> ;

M: float-array nth-unsafe
    float-array@ alien-double ;

M: float-array set-nth-unsafe
    [ >float ] 2dip float-array@ set-alien-double ;

: >float-array ( seq -- float-array )
    T{ float-array f 0 B{ } } clone-like ; inline

M: float-array like
    drop dup float-array? [ >float-array ] unless ;

M: float-array new-sequence
    drop <float-array> ;

M: float-array equal?
    over float-array? [ sequence= ] [ 2drop f ] if ;

M: float-array resize
    [ drop ] [
        [ floats>bytes ] [ underlying>> ] bi*
        resize-byte-array
    ] 2bi
    float-array boa ;

M: float-array byte-length length "double" heap-size * ;

INSTANCE: float-array sequence

: 1float-array ( x -- array )
    1 <float-array> [ set-first ] keep ; flushable

: 2float-array ( x y -- array )
    T{ float-array f 0 B{ } } 2sequence ; flushable

: 3float-array ( x y z -- array )
    T{ float-array f 0 B{ } } 3sequence ; flushable

: 4float-array ( w x y z -- array )
    T{ float-array f 0 B{ } } 4sequence ; flushable

: F{ ( parsed -- parsed )
    \ } [ >float-array ] parse-literal ; parsing

M: float-array pprint-delims drop \ F{ \ } ;

M: float-array >pprint-sequence ;
