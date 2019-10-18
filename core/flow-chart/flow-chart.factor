USING: kernel words math inference.dataflow sequences
optimizer.def-use combinators.private namespaces arrays
math.parser assocs prettyprint io strings inference hashtables ;
IN: flow-chart

GENERIC: flow-chart* ( n word -- value nodes )

M: word flow-chart*
    2drop f f ;

M: compound flow-chart*
    word-def swap 1+ [ drop <computed> ] map
    [ dataflow-with compute-def-use ] keep
    first dup used-by prune [ t eq? not ] subset ;

GENERIC: node-word ( node -- word )

M: #call node-word node-param ;

M: #if node-word drop \ if ;

M: #dispatch node-word drop \ dispatch ;

DEFER: flow-chart

: flow-chart-node ( value node -- )
    [ node-in-d <reversed> index ] keep
    node-word flow-chart , ;

SYMBOL: pruned

SYMBOL: nesting

SYMBOL: max-nesting

2 max-nesting set

: flow-chart ( n word -- seq )
    [
        2dup 2array ,
        nesting dup inc get max-nesting get > [
            2drop pruned ,
        ] [
            flow-chart* dup length 5 > [
                2drop pruned ,
            ] [
                [ flow-chart-node ] curry* each
            ] if
        ] if
    ] { } make ;

: th ( n -- )
    dup number>string write
    100 mod dup 20 > [ 10 mod ] when
    H{ { 1 "st" } { 2 "nd" } { 3 "rd" } } at "th" or write ;

: chart-heading. ( pair -- )
    first2 >r 1+ th " argument to " write r> . ;

GENERIC# show-chart 1 ( seq n -- )

: indent CHAR: \s <string> write ;

M: sequence show-chart
    dup indent
    >r unclip chart-heading. r>
    2 + [ show-chart ] curry each ;

M: word show-chart
    dup indent
    "... pruned" print ;

: flow-chart. ( n word -- )
    flow-chart 2 show-chart ;
