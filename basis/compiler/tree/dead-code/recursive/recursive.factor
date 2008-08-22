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
    [let* | new-inputs [ inputs make-values ]
            live-inputs [ outputs inputs filter-corresponding ]
            new-live-inputs [ outputs new-inputs filter-corresponding ]
            mapping [ new-live-inputs live-inputs zip ] |
        inputs filter-live
        new-live-inputs
        mapping
        #shuffle
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

:: drop-call-recursive-outputs ( node -- #shuffle )
    [let* | node-out [ node out-d>> ]
            return-in [ node label>> return>> in-d>> ]
            node-out-live [ return-in node-out filter-corresponding ]
            new-node-out-live [ node-out-live make-values ]
            node-out-dropped [ node-out filter-live ]
            new-node-out-dropped [ node-out-dropped new-node-out-live filter-corresponding ]
            mapping [ node-out-dropped new-node-out-dropped zip ] |
        node new-node-out-live >>out-d drop
        new-node-out-live node-out-dropped mapping #shuffle
    ] ;

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
