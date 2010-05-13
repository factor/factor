! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.data alien.parser alien.strings
alien.syntax arrays assocs byte-arrays classes.struct
combinators continuations cuda.ffi cuda.memory cuda.utils
destructors fry init io io.backend io.encodings.string
io.encodings.utf8 kernel lexer locals macros math math.parser
namespaces opengl.gl.extensions parser prettyprint quotations
sequences words cuda.libraries ;
QUALIFIED-WITH: alien.c-types c
IN: cuda

TUPLE: launcher
{ device integer initial: 0 }
{ device-flags initial: 0 } ;

: <launcher> ( device-id -- launcher )
    launcher new
        swap >>device ; inline

TUPLE: function-launcher
dim-grid dim-block shared-size stream ;

: with-cuda-context ( flags device quot -- )
    H{ } clone cuda-modules set-global
    H{ } clone cuda-functions set
    [ create-context ] dip 
    [ '[ _ @ ] ]
    [ drop '[ _ destroy-context ] ] 2bi
    [ ] cleanup ; inline

: with-cuda-program ( flags device quot -- )
    [ dup cuda-device set ] 2dip
    '[ cuda-context set _ call ] with-cuda-context ; inline

: with-cuda ( launcher quot -- )
    init-cuda [
        [ cuda-launcher set ]
        [ [ device>> ] [ device-flags>> ] bi ] bi
    ] [ with-cuda-program ] bi* ; inline

: c-type>cuda-setter ( c-type -- n cuda-type )
    {
        { [ dup c:int = ] [ drop 4 [ cuda-int* ] ] }
        { [ dup c:uint = ] [ drop 4 [ cuda-int* ] ] }
        { [ dup c:float = ] [ drop 4 [ cuda-float* ] ] }
        { [ dup c:pointer? ] [ drop 4 [ cuda-int* ] ] }
        { [ dup c:void* = ] [ drop 4 [ cuda-int* ] ] }
    } cond ;

<PRIVATE
: block-dim ( block -- x y z )
    dup sequence? [ 3 1 pad-tail first3 ] [ 1 1 ] if ; inline
: grid-dim ( block -- x y )
    dup sequence? [ 2 1 pad-tail first2 ] [ 1 ] if ; inline
PRIVATE>

: run-function-launcher ( function-launcher function -- )
    swap
    {
        [ dim-block>> block-dim function-block-shape* ]
        [ shared-size>> function-shared-size* ]
        [
            dim-grid>>
            [ grid-dim launch-function-grid* ]
            [ launch-function* ] if*
        ]
    } 2cleave ;

: cuda-argument-setter ( offset c-type -- offset' quot )
    c-type>cuda-setter
    [ over [ + ] dip ] dip
    '[ swap _ swap _ call ] ;

MACRO: cuda-arguments ( c-types -- quot: ( args... function -- ) )
    [ 0 ] dip [ cuda-argument-setter ] map reverse
    swap '[ _ param-size* ] suffix
    '[ _ cleave ] ;

: define-cuda-word ( word module-name function-name arguments -- )
    [
        '[
            _ _ cached-function
            [ nip _ cuda-arguments ]
            [ run-function-launcher ] 2bi
        ]
    ]
    [ 2nip \ function-launcher suffix c:void function-effect ]
    3bi define-declared ;
