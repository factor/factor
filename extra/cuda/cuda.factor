! Copyright (C) 2010 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors alien alien.data alien.parser alien.strings
alien.syntax arrays assocs byte-arrays classes.struct
combinators continuations cuda.ffi cuda.memory cuda.utils
destructors fry io io.backend io.encodings.string
io.encodings.utf8 kernel lexer locals macros math math.parser
namespaces nested-comments opengl.gl.extensions parser
prettyprint quotations sequences words ;
QUALIFIED-WITH: alien.c-types a
IN: cuda

TUPLE: launcher
{ device integer initial: 0 }
{ device-flags initial: 0 } ;

TUPLE: function-launcher
dim-block dim-grid shared-size stream ;

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
    init-cuda
    [ H{ } clone cuda-memory-hashtable ] 2dip '[
        _ 
        [ cuda-launcher set ]
        [ [ device>> ] [ device-flags>> ] bi ] bi
        _ with-cuda-program
    ] with-variable ; inline

: c-type>cuda-setter ( c-type -- n cuda-type )
    {
        { [ dup a:int = ] [ drop 4 [ cuda-int* ] ] }
        { [ dup a:uint = ] [ drop 4 [ cuda-int* ] ] }
        { [ dup a:float = ] [ drop 4 [ cuda-float* ] ] }
        { [ dup a:pointer? ] [ drop 4 [ ptr>> cuda-int* ] ] }
        { [ dup a:void* = ] [ drop 4 [ ptr>> cuda-int* ] ] }
    } cond ;

: run-function-launcher ( function-launcher function -- )
    swap
    {
        [ dim-block>> first3 function-block-shape* ]
        [ shared-size>> function-shared-size* ]
        [
            dim-grid>> [
                launch-function*
            ] [
                first2 launch-function-grid*
            ] if-empty
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
    [ 2nip \ function-launcher suffix a:void function-effect ]
    3bi define-declared ;
