! Copyright (C) 2006, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: classes inference inference.dataflow io kernel
kernel.private math.parser namespaces optimizer prettyprint
prettyprint.backend sequences words arrays match macros
assocs sequences.private optimizer.specializers generic
combinators sorting math quotations ;
IN: optimizer.debugger

! A simple tool for turning dataflow IR into quotations, for
! debugging purposes.

GENERIC: node>quot ( ? node -- )

TUPLE: comment node text ;

M: comment pprint*
    "( " over comment-text " )" 3append
    swap comment-node present-text ;

: comment, ( ? node text -- )
    rot [ \ comment boa , ] [ 2drop ] if ;

: values% ( prefix values -- )
    swap [
        %
        dup value? [
            value-literal unparse %
        ] [
            "@" % unparse %
        ] if
    ] curry each ;

: effect-str ( node -- str )
    [
        " " over node-in-d values%
        " r: " over node-in-r values%
        " --" %
        " " over node-out-d values%
        " r: " swap node-out-r values%
    ] "" make 1 tail ;

MACRO: match-choose ( alist -- )
    [ [ ] curry ] assoc-map [ match-cond ] curry ;

MATCH-VARS: ?a ?b ?c ;

: pretty-shuffle ( in out -- word/f )
    2array {
        { { { ?a } { } } drop }
        { { { ?a ?b } { } } 2drop }
        { { { ?a ?b ?c } { } } 3drop }
        { { { ?a } { ?a ?a } } dup }
        { { { ?a ?b } { ?a ?b ?a ?b } } 2dup }
        { { { ?a ?b ?c } { ?a ?b ?c ?a ?b ?c } } 3dup }
        { { { ?a ?b } { ?a ?b ?a } } over }
        { { { ?b ?a } { ?a ?b } } swap }
        { { { ?a ?b ?c } { ?a ?b ?c ?a } } pick }
        { { { ?a ?b ?c } { ?c ?a ?b } } -rot }
        { { { ?a ?b ?c } { ?b ?c ?a } } rot }
        { { { ?a ?b } { ?b } } nip }
        { _ f }
    } match-choose ;

M: #shuffle node>quot
    dup node-in-d over node-out-d pretty-shuffle
    [ , ] [ >r drop t r> ] if*
    dup effect-str "#shuffle: " prepend comment, ;

: pushed-literals node-out-d [ value-literal literalize ] map ;

M: #push node>quot nip pushed-literals % ;

DEFER: dataflow>quot

: #call>quot ( ? node -- )
    dup node-param dup ,
    [ dup effect-str ] [ "empty call" ] if comment, ;

M: #call node>quot #call>quot ;

M: #call-label node>quot #call>quot ;

M: #label node>quot
    [
        dup node-param literalize ,
        dup #label-loop? "#loop: " "#label: " ?
        over node-param word-name append comment,
    ] 2keep
    node-child swap dataflow>quot , \ call ,  ;

M: #if node>quot
    [ "#if" comment, ] 2keep
    node-children swap [ dataflow>quot ] curry map %
    \ if , ;

M: #dispatch node>quot
    [ "#dispatch" comment, ] 2keep
    node-children swap [ dataflow>quot ] curry map ,
    \ dispatch , ;

M: #>r node>quot nip node-in-d length \ >r <array> % ;

M: #r> node>quot nip node-out-d length \ r> <array> % ;

M: object node>quot
    [
        dup class word-name %
        " " %
        dup node-param unparse %
        " " %
        dup effect-str %
    ] "" make comment, ;

: (dataflow>quot) ( ? node -- )
    dup [
        2dup node>quot node-successor (dataflow>quot)
    ] [
        2drop
    ] if ;

: dataflow>quot ( node ? -- quot )
    [ swap (dataflow>quot) ] [ ] make ;

: optimized-quot. ( quot ? -- )
    #! Print dataflow IR for a quotation. Flag indicates if
    #! annotations should be printed or not.
    >r dataflow optimize r> dataflow>quot pprint nl ;

: optimized-word. ( word ? -- ) >r specialized-def r> optimized-quot. ;

SYMBOL: words-called
SYMBOL: generics-called
SYMBOL: methods-called
SYMBOL: intrinsics-called
SYMBOL: node-count

: dataflow>report ( node -- alist )
    [
        H{ } clone words-called set
        H{ } clone generics-called set
        H{ } clone methods-called set
        H{ } clone intrinsics-called set

        0 swap [
            >r 1+ r>
            dup #call? [
                node-param {
                    { [ dup "intrinsics" word-prop over "if-intrinsics" word-prop or ] [ intrinsics-called ] }
                    { [ dup generic? ] [ generics-called ] }
                    { [ dup method-body? ] [ methods-called ] }
                    [ words-called ]
                } cond 1 -rot get at+
            ] [
                drop
            ] if
        ] each-node
        node-count set
    ] H{ } make-assoc ;

: quot-optimize-report ( quot -- report )
    dataflow optimize dataflow>report ;

: word-optimize-report ( word -- report )
    word-def quot-optimize-report ;

: report. ( report -- )
    [
        "==== Total number of dataflow nodes:" print
        node-count get .

        {
            { generics-called "==== Generic word calls:" }
            { words-called "==== Ordinary word calls:" }
            { methods-called "==== Non-inlined method calls:" }
            { intrinsics-called "==== Open-coded intrinsic calls:" }
        } [
            nl print get keys natural-sort stack.
        ] assoc-each
    ] bind ;

: optimizer-report. ( word -- )
    word-optimize-report report. ;
