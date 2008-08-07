! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces sequences assocs math kernel accessors fry
combinators sets locals
compiler.tree
compiler.tree.def-use
compiler.tree.combinators ;
IN: compiler.tree.copy-equiv

! This is not really a compiler pass; its invoked as part of
! propagation.

! Two values are copy-equivalent if they are always identical
! at run-time ("DS" relation). This is just a weak form of
! value numbering.

! Mapping from values to their canonical leader
SYMBOL: copies

:: compress-path ( source assoc -- destination )
    [let | destination [ source assoc at ] |
        source destination = [ source ] [
            [let | destination' [ destination assoc compress-path ] |
                destination' destination = [
                    destination' source assoc set-at
                ] unless
                destination'
            ]
        ] if
    ] ;

: resolve-copy ( copy -- val ) copies get compress-path ;

: is-copy-of ( val copy -- ) copies get set-at ;

: are-copies-of ( vals copies -- ) [ is-copy-of ] 2each ;

: introduce-value ( val -- ) copies get conjoin ;

GENERIC: compute-copy-equiv* ( node -- )

M: #shuffle compute-copy-equiv*
    [ out-d>> dup ] [ mapping>> ] bi
    '[ , at ] map swap are-copies-of ;

M: #>r compute-copy-equiv*
    [ in-d>> ] [ out-r>> ] bi are-copies-of ;

M: #r> compute-copy-equiv*
    [ in-r>> ] [ out-d>> ] bi are-copies-of ;

M: #copy compute-copy-equiv*
    [ in-d>> ] [ out-d>> ] bi are-copies-of ;

M: #return-recursive compute-copy-equiv*
    [ in-d>> ] [ out-d>> ] bi are-copies-of ;

: compute-phi-equiv ( inputs outputs -- )
    #! An output is a copy of every input if all inputs are
    #! copies of the same original value.
    [
        swap sift [ resolve-copy ] map
        dup [ all-equal? ] [ empty? not ] bi and
        [ first swap is-copy-of ] [ 2drop ] if
    ] 2each ;

M: #phi compute-copy-equiv*
    [ [ phi-in-d>> ] [ out-d>> ] bi compute-phi-equiv ]
    [ [ phi-in-r>> ] [ out-r>> ] bi compute-phi-equiv ] bi ;

M: node compute-copy-equiv* drop ;

: compute-copy-equiv ( node -- )
    [ node-defs-values [ introduce-value ] each ]
    [ compute-copy-equiv* ]
    bi ;
