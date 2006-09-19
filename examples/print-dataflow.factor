IN: print-dataflow
USING: generic hashtables inference io kernel kernel-internals
math namespaces prettyprint sequences styles vectors words
test optimizer ;

! A simple tool for turning dataflow IR into quotations, for
! debugging purposes.

GENERIC: node>quot ( ? node -- )

TUPLE: comment node text ;

M: comment pprint*
    "( " over comment-text " )" append3
    swap comment-node presented associate
    styled-text ;

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
    ] "" make 1 tail ;

M: #shuffle node>quot
    >r drop t r> dup effect-str "#shuffle: " swap append comment, ;

M: #push node>quot nip >#push< % ;

DEFER: dataflow>quot

: #call>quot ( ? node -- )
    dup node-param dup
    [ , dup effect-str comment, ] [ 3drop ] if ;

M: #call node>quot #call>quot ;

M: #call-label node>quot #call>quot ;

M: #label node>quot
    [ "#label: " over node-param word-name append comment, ] 2keep
    node-child swap dataflow>quot , \ call ,  ;

M: #if node>quot
    [ "#if" comment, ] 2keep
    node-children [ swap dataflow>quot ] map-with % \ if , ;

M: #dispatch node>quot
    [ "#dispatch" comment, ] 2keep
    node-children [ swap dataflow>quot ] map-with , \ dispatch , ;

M: #return node>quot
    dup node-param unparse "#return " swap append comment, ;

M: object node>quot dup class word-name comment, ;

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

[ ] [ [ 2 ] t dataflow. ] unit-test
[ ] [ [ 3 + ] t dataflow. ] unit-test
[ ] [ [ drop ] t dataflow. ] unit-test
[ ] [ [ [ sq ] [ abs ] if ] t dataflow. ] unit-test
[ ] [ [ { [ sq ] [ abs ] } dispatch ] t dataflow. ] unit-test
[ ] [ \ unify-values word-def t dataflow. ] unit-test
[ ] [ [ 0 0 / ] t dataflow. ] unit-test
