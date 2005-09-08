IN: inference
USING: generic hashtables inference io kernel kernel-internals
lists math namespaces prettyprint sequences styles vectors words ;

! A simple tool for turning dataflow IR into quotations, for
! debugging purposes.

GENERIC: node>quot ( node -- )

TUPLE: comment node text ;

M: comment pprint* ( ann -- )
    "( " over comment-text " )" append3
    swap comment-node presented swons unit text ;

: comment, ( ? node text -- )
    rot [ <comment> , ] [ 2drop ] ifte ;

: values% ( prefix values -- )
    [
        swap %
        dup literal? [ literal-value ] [ value-uid ] ifte
        unparse %
    ] each-with ;

: effect-str ( node -- str )
    [
        " " over node-in-d values%
        " r: " over node-in-r values%
        " --" %
        " " over node-out-d values%
        " r: " swap node-out-r values%
    ] "" make 1 swap tail ;

M: #shuffle node>quot ( ? node -- )
    >r drop t r> dup effect-str "#shuffle: " swap append comment, ;

DEFER: dataflow>quot

: #call>quot ( ? node -- )
    dup node-param dup
    [ , dup effect-str comment, ] [ 3drop ] ifte ;

M: #call node>quot ( ? node -- ) #call>quot ;

M: #call-label node>quot ( ? node -- ) #call>quot ;

M: #label node>quot ( ? node -- )
    [ "#label: " over node-param word-name append comment, ] 2keep
    node-child swap dataflow>quot , \ call ,  ;

M: #ifte node>quot ( ? node -- )
    [ "#ifte" comment, ] 2keep
    node-children [ swap dataflow>quot ] map-with % \ ifte , ;

M: #dispatch node>quot ( ? node -- )
    [ "#dispatch" comment, ] 2keep
    node-children [ swap dataflow>quot ] map-with , \ dispatch , ;

M: #return node>quot ( ? node -- ) "#return" comment, ;

M: #values node>quot ( ? node -- ) "#values" comment, ;

M: #merge node>quot ( ? node -- ) "#merge" comment, ;

M: #entry node>quot ( ? node -- ) "#entry" comment, ;

: (dataflow>quot) ( ? node -- )
    dup [
        2dup node>quot node-successor (dataflow>quot)
    ] [
        2drop
    ] ifte ;

: dataflow>quot ( node ? -- quot )
    [ swap (dataflow>quot) ] [ ] make ;

: dataflow. ( quot ? -- )
    #! Print dataflow IR for a quotation. Flag indicates if
    #! annotations should be printed or not.
    >r dataflow optimize r> dataflow>quot . ;
