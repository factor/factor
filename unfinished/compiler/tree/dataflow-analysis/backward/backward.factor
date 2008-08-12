! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: compiler.tree.dataflow-analysis.backward
USING: accessors sequences assocs kernel compiler.tree
compiler.tree.dataflow-analysis ;

GENERIC: backward ( value node -- )

M: #copy backward
    #! If the output of a copy is live, then the corresponding
    #! input is live also.
    [ out-d>> index ] keep in-d>> nth look-at-value ;

M: #call backward
    #! If any of the outputs of a call are live, then all
    #! inputs and outputs must be live.
    nip [ look-at-inputs ] [ look-at-outputs ] bi ;

M: #call-recursive backward
    #! If the output of a copy is live, then the corresponding
    #! inputs to #return nodes are live also.
    [ out-d>> <reversed> index ] keep label>> returns>>
    [ <reversed> nth look-at-value ] with each ;

M: #>r backward nip in-d>> first look-at-value ;

M: #r> backward nip in-r>> first look-at-value ;

M: #shuffle backward mapping>> at look-at-value ;

M: #phi backward
    #! If any of the outputs of a #phi are live, then the
    #! corresponding inputs are live too.
    [ [ out-d>> ] [ phi-in-d>> ] bi look-at-corresponding ]
    [ [ out-r>> ] [ phi-in-r>> ] bi look-at-corresponding ]
    2bi ;

M: #alien-invoke backward
    nip [ look-at-inputs ] [ look-at-outputs ] bi ;

M: #alien-indirect backward
    nip [ look-at-inputs ] [ look-at-outputs ] bi ;

M: node backward 2drop ;

: backward-dfa ( node quot -- assoc ) [ backward ] dfa ; inline
