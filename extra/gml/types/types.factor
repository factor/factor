! Copyright (C) 2010 Slava Pestov.
USING: accessors kernel math sequences sequences.private
hashtables assocs locals arrays combinators classes.struct
math.vectors math.vectors.simd math.vectors.simd.cords ;
IN: gml.types

: true? ( obj -- ? ) 0 number= not ; inline
: >true ( ? -- 1/0 ) 1 0 ? ; inline

TUPLE: proc { array array read-only } { registers array read-only } ;

C: <proc> proc

M: proc clone [ array>> clone ] [ registers>> clone ] bi <proc> ;

M: proc length array>> length ;
M: proc nth-unsafe array>> nth-unsafe ;
M: proc set-nth-unsafe array>> set-nth-unsafe ;
M: proc like drop dup proc? [ { } like { } <proc> ] unless ;
M: proc new-sequence drop 0 <array> { } <proc> ;

INSTANCE: proc sequence

: wrap ( n seq -- n seq ) [ length rem ] keep ; inline

GENERIC#: (gml-get) 1 ( collection key -- elt )

M: sequence (gml-get) swap wrap nth ;
M: hashtable (gml-get) of ;

GENERIC#: (gml-put) 2 ( collection key elt -- )

M:: sequence (gml-put) ( collection key elt -- )
    elt key collection wrap set-nth ;
M:: hashtable (gml-put) ( collection key elt -- )
    elt key collection set-at ;

GENERIC: (gml-copy) ( collection -- collection' )

M: array (gml-copy) clone ;
M: hashtable (gml-copy) clone ;
M: proc (gml-copy) clone ;

ALIAS: vec2d? double-2?

ALIAS: <vec2d> double-2-boa

ALIAS: scalar>vec2d double-2-with

ALIAS: vec3d? double-4?

: <vec3d> ( x y z -- vec ) 0.0 double-4-boa ; inline

: scalar>vec3d ( x -- vec ) dup dup 0.0 double-4-boa ; inline

GENERIC: mask-vec3d ( value -- value' )

M: double-2 mask-vec3d ; inline

M: double-4 mask-vec3d
    longlong-4{ -1 -1 -1 0 } double-4-cast vbitand ; inline
