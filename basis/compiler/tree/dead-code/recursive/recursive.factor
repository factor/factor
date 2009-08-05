! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs sequences kernel locals fry
combinators stack-checker.backend
compiler.tree
compiler.tree.recursive
compiler.tree.dead-code.branches
compiler.tree.dead-code.liveness
compiler.tree.dead-code.simple ;
IN: compiler.tree.dead-code.recursive

M: #enter-recursive compute-live-values*
    #! If the output of an #enter-recursive is live, then the
    #! corresponding inputs to the #call-recursive are live also.
    [ out-d>> ] [ recursive-phi-in ] bi look-at-phi ;

M: #return-recursive compute-live-values*
    [ out-d>> ] [ in-d>> ] bi look-at-mapping ;

M: #call-recursive compute-live-values*
    #! If the output of a #call-recursive is live, then the
    #! corresponding inputs to #return nodes are live also.
    [ out-d>> ] [ label>> return>> in-d>> ] bi look-at-mapping ;

:: drop-dead-inputs ( inputs outputs -- #shuffle )
    inputs filter-live
    outputs inputs filter-corresponding make-values
    outputs
    inputs
    drop-values ;

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

:: drop-recursive-inputs ( node -- shuffle )
    [let* | shuffle [ node [ in-d>> ] [ label>> enter-out>> ] bi drop-dead-inputs ]
            new-outputs [ shuffle out-d>> ] |
        node new-outputs
        [ [ label>> enter-recursive>> ] dip >>in-d drop ] [ >>in-d drop ] 2bi
        shuffle
    ] ;

:: drop-recursive-outputs ( node -- shuffle )
    [let* | return [ node label>> return>> ]
            new-inputs [ return in-d>> filter-live ]
            new-outputs [ return [ in-d>> ] [ out-d>> ] bi filter-corresponding ] |
        return
        [ new-inputs >>in-d new-outputs >>out-d drop ]
        [ drop-dead-outputs ]
        bi
    ] ;

M: #recursive remove-dead-code* ( node -- nodes )
    [ drop-recursive-inputs ]
    [
        [ (remove-dead-code) ] change-child
        dup label>> [ filter-live ] change-enter-out drop
    ]
    [ drop-recursive-outputs ] tri 3array ;

M: #return-recursive remove-dead-code* ;
