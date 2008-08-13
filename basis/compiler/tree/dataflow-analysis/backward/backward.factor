! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler.tree.dataflow-analysis.backward
USING: accessors sequences assocs kernel compiler.tree
compiler.tree.dataflow-analysis ;

GENERIC: backward ( value node -- )

M: #copy backward
    #! If the output of a copy is live, then the corresponding
    #! input is live also.
    [ out-d>> ] [ in-d>> ] bi look-at-mapping ;

M: #call backward nip look-at-inputs ;

M: #call-recursive backward
    #! If the output of a copy is live, then the corresponding
    #! inputs to #return nodes are live also.
    [ out-d>> ] [ label>> return>> ] bi look-at-mapping ;

M: #>r backward [ out-r>> ] [ in-d>> ] bi look-at-mapping ;

M: #r> backward [ out-d>> ] [ in-r>> ] bi look-at-mapping ;

M: #shuffle backward mapping>> at look-at-value ;

M: #phi backward
    #! If any of the outputs of a #phi are live, then the
    #! corresponding inputs are live too.
    [ [ out-d>> ] [ phi-in-d>> ] bi look-at-phi ]
    [ [ out-r>> ] [ phi-in-r>> ] bi look-at-phi ]
    2bi ;

M: #enter-recursive backward
    [ out-d>> ] [ recursive-phi-in flip ] bi look-at-phi ;

: return-recursive-phi-in ( #return-recursive -- phi-in )
    [ label>> calls>> [ in-d>> ] map ] [ in-d>> ] bi suffix ;

M: #return-recursive backward
    [ out-d>> ] [ return-recursive-phi-in flip ] bi look-at-phi ;

M: #alien-invoke backward nip look-at-inputs ;

M: #alien-indirect backward nip look-at-inputs ;

M: node backward 2drop ;

: backward-dfa ( node quot -- assoc ) [ backward ] dfa ; inline
