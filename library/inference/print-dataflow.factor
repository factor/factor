IN: inference
USING: generic hashtables inference io kernel kernel-internals
math namespaces prettyprint sequences vectors words ;

! A simple tool for turning dataflow IR into quotations, for
! debugging purposes.

GENERIC: node>quot ( node -- )

TUPLE: annotation node text ;

M: annotation prettyprint* ( ann -- )
    "( " over annotation-text " )" append3
    swap annotation-node object. ;

: value-str ( classes values -- str )
    [ swap ?hash [ object ] unless* ] map-with
    [ word-name ] map
    " " join ;

: effect-str ( node -- str )
    [
        dup node-classes swap
        2dup node-in-d value-str %
        "--" %
        node-out-d value-str %
    ] make-string ;

M: #push node>quot ( node -- )
    node-out-d [ literal-value literalize ] map concat % ;

M: #drop node>quot ( node -- )
    node-in-d length dup 3 > [
        \ drop <repeated>
    ] [
        { f [ drop ] [ 2drop ] [ 3drop ] } nth
    ] ifte % ;

DEFER: dataflow>quot

M: #call node>quot ( node -- )
    dup node-param , dup effect-str <annotation> , ;

M: #call-label node>quot ( node -- )
    "#call-label: " over node-param word-name append <annotation> , ;

M: #label node>quot ( node -- )
    dup "#label: " over node-param word-name append <annotation> ,
    node-children first dataflow>quot , \ call ,  ;

M: #ifte node>quot ( node -- )
    dup "#ifte" <annotation> ,
    node-children [ dataflow>quot ] map % \ ifte , ;

M: #dispatch node>quot ( node -- )
    dup "#dispatch" <annotation> ,
    node-children [ dataflow>quot ] map >vector % \ dispatch , ;

M: #return node>quot ( node -- ) "#return" <annotation> , ;

M: #values node>quot ( node -- ) "#values" <annotation> , ;

M: #merge node>quot ( node -- ) "#merge" <annotation> , ;

: (dataflow>quot) ( node -- )
    [ dup node>quot node-successor (dataflow>quot) ] when* ;

: dataflow>quot ( node -- quot )
    [ (dataflow>quot) ] make-list ;

: dataflow. ( quot -- )
    #! Print dataflow IR for a word.
    dataflow>quot prettyprint ;
