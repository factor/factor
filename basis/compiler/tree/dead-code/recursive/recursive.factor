! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs sequences kernel locals fry
combinators stack-checker.backend
compiler.tree
compiler.tree.dead-code.branches
compiler.tree.dead-code.liveness
compiler.tree.dead-code.simple ;
IN: compiler.tree.dead-code.recursive

M: #enter-recursive compute-live-values*
    #! If the output of an #enter-recursive is live, then the
    #! corresponding inputs to the #call-recursive are live also.
    [ out-d>> ] [ recursive-phi-in ] bi look-at-phi ;

: return-recursive-phi-in ( #return-recursive -- phi-in )
    [ label>> calls>> [ in-d>> ] map ] [ in-d>> ] bi suffix ;

M: #return-recursive compute-live-values*
    [ out-d>> ] [ return-recursive-phi-in ] bi look-at-phi ;

M: #call-recursive compute-live-values*
    #! If the output of a #call-recursive is live, then the
    #! corresponding inputs to #return nodes are live also.
    [ out-d>> ] [ label>> return>> in-d>> ] bi look-at-mapping ;

:: drop-dead-inputs ( inputs outputs -- #shuffle )
    [let* | live-inputs [ inputs filter-live ]
            new-live-inputs [ outputs inputs filter-corresponding make-values ] |
        live-inputs
        new-live-inputs
        outputs
        inputs
        drop-values
    ] ;

M: #recursive remove-dead-code* ( node -- nodes )
    dup [ in-d>> ] [ label>> enter-out>> ] bi drop-dead-inputs
    {
        [ [ dup label>> enter-recursive>> ] [ out-d>> ] bi* '[ , >>in-d drop ] bi@ ]
        [ drop [ (remove-dead-code) ] change-child drop ]
        [ drop label>> [ filter-live ] change-enter-out drop ]
        [ swap 2array ]
    } 2cleave ;

M: #enter-recursive remove-dead-code*
    [ filter-live ] change-out-d ;

: drop-call-recursive-inputs ( node -- #shuffle )
    dup [ in-d>> ] [ label>> enter-out>> ] bi drop-dead-inputs
    [ out-d>> >>in-d drop ]
    [ nip ]
    2bi ;

:: (drop-call-recursive-outputs) ( inputs outputs -- #shuffle )
    [let* | new-live-outputs [ inputs outputs filter-corresponding make-values ]
            live-outputs [ outputs filter-live ] |
        new-live-outputs
        live-outputs
        live-outputs
        new-live-outputs
        drop-values
    ] ;

: drop-call-recursive-outputs ( node -- #shuffle )
    dup [ label>> return>> in-d>> ] [ out-d>> ] bi
    (drop-call-recursive-outputs)
    [ in-d>> >>out-d drop ] keep ;

M: #call-recursive remove-dead-code*
    [ drop-call-recursive-inputs ]
    [ ]
    [ drop-call-recursive-outputs ]
    tri 3array ;

M: #return-recursive remove-dead-code* ( node -- nodes )
    dup [ in-d>> ] [ out-d>> ] bi drop-dead-inputs
    [ drop [ filter-live ] change-out-d drop ]
    [ out-d>> >>in-d drop ]
    [ swap 2array ]
    2tri ;
