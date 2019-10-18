! Copyright (C) 2010 Slava Pestov.
USING: accessors arrays assocs classes gml.runtime gml.types
hashtables io io.styles kernel math math.parser math.vectors.simd
math.vectors.simd.cords sequences strings colors ;
IN: gml.printer

GENERIC: write-gml ( obj -- )

M: object write-gml "«Object: " write name>> write "»" write ;
M: integer write-gml number>string write ;
M: float write-gml number>string write ;
M: string write-gml "\"" write write "\"" write ;
M: gml-name write-gml "/" write string>> write ;
M: gml-exec-name write-gml name>> string>> write ;
M: pathname write-gml names>> [ "." write string>> write ] each ;
M: use-registers write-gml drop "usereg" write ;
M: read-register write-gml ";" write name>> write ;
M: exec-register write-gml ":" write name>> write ;
M: write-register write-gml "!" write name>> write ;

: write-vector ( vec n -- )
    head-slice
    "(" write [ "," write ] [ number>string write ] interleave ")" write ;
M: double-2 write-gml 2 write-vector ;

M: array write-gml
    "[" write [ bl ] [ write-gml ] interleave "]" write ;
M: proc write-gml
    "{" write array>> [ bl ] [ write-gml ] interleave "}" write ;
M: hashtable write-gml
    "«Dictionary with " write
    assoc-size number>string write
    " entries»" write ;

: print-gml ( obj -- ) write-gml nl ;

CONSTANT: vertex-colors
    {
        T{ rgba f   0.   0. 2/3. 1. }
        T{ rgba f   0. 2/3.   0. 1. }
        T{ rgba f   0. 2/3. 2/3. 1. }
        T{ rgba f 2/3.   0.   0. 1. }
        T{ rgba f 2/3.   0. 2/3. 1. }
        T{ rgba f 2/3. 1/3.   0. 1. }
        T{ rgba f   0.   0.   1. 1. }
        T{ rgba f   0.   1.   0. 1. }
        T{ rgba f   0.   1.   1. 1. }
        T{ rgba f   1.   0.   0. 1. }
        T{ rgba f   1.   0.   1. 1. }
        T{ rgba f   1.   1.   0. 1. }
    }

: vertex-color ( position -- rgba )
    first3 [ [ >float double>bits ] [ >integer ] bi + ] tri@
    bitxor bitxor vertex-colors length mod vertex-colors nth ;

: vertex-style ( position -- rgba )
    vertex-color foreground associate ;

M: double-4 write-gml dup vertex-style [ 3 write-vector ] with-style ;
