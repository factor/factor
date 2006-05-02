IN: optimizer
USING: generic hashtables inference io kernel kernel-internals
lists math namespaces prettyprint sequences styles vectors words ;

! A simple tool for turning dataflow IR into quotations, for
! debugging purposes.

GENERIC: node>quot ( node -- )

TUPLE: comment node text ;

M: comment pprint* ( ann -- )
    "( " over comment-text " )" append3
    swap comment-node presented associate text ;

: comment, ( ? node text -- )
    rot [ <comment> , ] [ 2drop ] if ;

: values% ( prefix values -- )
    [
        swap %
        dup value? [
            value-literal unparse %
        ] [
            "@" % #
        ] if
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

M: #push node>quot ( ? node -- ) nip >#push< % ;

DEFER: dataflow>quot

: #call>quot ( ? node -- )
    dup node-param dup
    [ , dup effect-str comment, ] [ 3drop ] if ;

M: #call node>quot ( ? node -- ) #call>quot ;

M: #call-label node>quot ( ? node -- ) #call>quot ;

M: #label node>quot ( ? node -- )
    [ "#label: " over node-param word-name append comment, ] 2keep
    node-child swap dataflow>quot , \ call ,  ;

M: #if node>quot ( ? node -- )
    [ "#if" comment, ] 2keep
    node-children [ swap dataflow>quot ] map-with % \ if , ;

M: #dispatch node>quot ( ? node -- )
    [ "#dispatch" comment, ] 2keep
    node-children [ swap dataflow>quot ] map-with , \ dispatch , ;

M: #return node>quot ( ? node -- )
    dup node-param unparse "#return " swap append comment, ;

M: object node>quot ( ? node -- ) dup class comment, ;

: (dataflow>quot) ( ? node -- )
    dup [
        2dup node>quot node-successor (dataflow>quot)
    ] [
        2drop
    ] if ;

: dataflow>quot ( node ? -- quot )
    [ swap (dataflow>quot) ] [ ] make ;

: dataflow. ( quot ? -- )
    #! Print dataflow IR for a quotation. Flag indicates if
    #! annotations should be printed or not.
    >r dataflow optimize r> dataflow>quot . ;
