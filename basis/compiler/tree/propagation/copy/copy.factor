! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs combinators.short-circuit compiler.tree
compiler.tree.def-use compiler.utilities grouping kernel
namespaces sequences sets stack-checker.branches ;
IN: compiler.tree.propagation.copy

SYMBOL: copies

: resolve-copy ( copy -- val ) copies get compress-path ;

: resolve-copies ( copies -- vals ) copies get '[ _ compress-path ] map ;

: is-copy-of ( val copy -- ) copies get set-at ;

: are-copies-of ( vals copies -- ) copies get '[ _ set-at ] 2each ;

: introduce-value ( val -- ) copies get conjoin ;

: introduce-values ( vals -- ) copies get '[ _ conjoin ] each ;

GENERIC: compute-copy-equiv* ( node -- )

M: #renaming compute-copy-equiv* inputs/outputs are-copies-of ;

: compute-phi-equiv ( inputs outputs -- )
    copies get '[
        swap remove-bottom resolve-copies
        dup [ f ] [ all-equal? ] if-empty
        [ first swap _ set-at ] [ 2drop ] if
    ] 2each ;

M: #phi compute-copy-equiv*
    [ phi-in-d>> flip ] [ out-d>> ] bi compute-phi-equiv ;

M: node compute-copy-equiv* drop ;

: compute-copy-equiv ( node -- )
    [ node-defs-values introduce-values ]
    [ compute-copy-equiv* ]
    bi ;
