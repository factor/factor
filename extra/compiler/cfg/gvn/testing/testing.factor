! Copyright (C) 2011 Alex Vondrak.  See
! http://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.cfg
compiler.cfg.alias-analysis compiler.cfg.block-joining
compiler.cfg.branch-splitting compiler.cfg.copy-prop
compiler.cfg.dce compiler.cfg.debugger
compiler.cfg.finalization compiler.cfg.graphviz
compiler.cfg.gvn compiler.cfg.gvn.expressions
compiler.cfg.gvn.graph compiler.cfg.height
compiler.cfg.ssa.construction compiler.cfg.tco
compiler.cfg.useless-conditionals formatting fry graphviz
graphviz.notation graphviz.render io kernel math math.parser
math.private namespaces prettyprint sequences sorting strings
tools.annotations ;
IN: compiler.cfg.gvn.testing

GENERIC: expr>str ( expr -- str )

M: integer-expr expr>str value>> number>string ;

M: reference-expr expr>str value>> number>string "&" prepend ;

M: object expr>str [ unparse ] map " " join ;

: local-value-mapping ( from to -- str )
    over exprs>vns get value-at* [
        expr>str "%d -> <%d> (%s)\\l" sprintf
    ] [
        drop "%d -> <%d>\\l" sprintf
    ] if ;

: lvns ( -- str )
    vregs>vns get >alist natural-sort [
        first2 local-value-mapping
    ] map "" concat-as ;

: invert-assoc ( assoc -- inverted )
    V{ } clone [
        [ push-at ] curry assoc-each
    ] keep ;

: gvns ( -- str )
    vregs>gvns get invert-assoc >alist natural-sort [
        first2
        natural-sort [ number>string ] map ", " join
        "<%d> : {%s}\\l" sprintf
    ] map "" concat-as ;

SYMBOL: gvn-test

[ 0 100 [ 1 fixnum+fast ] times ]
test-builder first [
    optimize-tail-calls
    delete-useless-conditionals
    split-branches
    join-blocks
    normalize-height
    construct-ssa
    alias-analysis
] with-cfg gvn-test set-global

: basic-block# ( -- n )
    basic-block get number>> ;

: add-gvns ( graph -- graph' )
    <anon>
        "gvns" add-node[ gvns =label "plaintext" =shape ];
        "gvns" 0 add-edge[ "invis" =style ];
    add ;

: add-lvns ( graph -- graph' )
    "lvn" <cluster>
        "invis" =style
        "lvns" add-node[ lvns =label "plaintext" =shape ];
        basic-block# add-node[ "bold" =style ];
    add ;

: draw-annotated-cfg ( -- )
    cfg get cfgviz add-gvns add-lvns
    basic-block# number>string "bb" prepend png ;

: watch-gvn ( -- )
    \ value-numbering-step
    [ '[ _ call draw-annotated-cfg ] ] annotate ;

: reset-gvn ( -- )
    \ value-numbering-step reset ;

: test-gvn ( -- )
    watch-gvn
    gvn-test get-global [
        {
            value-numbering
            copy-propagation
            eliminate-dead-code
            finalize-cfg
        } [ watch-pass ] each-index drop
    ] with-cfg
    reset-gvn ;
