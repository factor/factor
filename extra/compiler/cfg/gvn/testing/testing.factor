! Copyright (C) 2011 Alex Vondrak.  See
! http://factorcode.org/license.txt for BSD license.
USING: accessors assocs compiler.cfg compiler.cfg.graphviz
compiler.cfg.gvn compiler.cfg.gvn.expressions
compiler.cfg.gvn.graph compiler.cfg.optimizer continuations
formatting graphviz graphviz.notation graphviz.render
io.directories kernel math.parser namespaces prettyprint
sequences sorting splitting tools.annotations ;
IN: compiler.cfg.gvn.testing

GENERIC: expr>str ( expr -- str )

M: integer-expr expr>str value>> number>string ;

M: reference-expr expr>str value>> unparse ;

M: sequence expr>str [ unparse ] map " " join ;

M: object expr>str unparse ;

: value-mapping ( from to -- str )
    over exprs>vns get value-at* [
        expr>str "%d -> <%d> (%s)\\l" sprintf
    ] [
        drop "%d -> <%d>\\l" sprintf
    ] if ;

: gvns ( -- str )
    vregs>vns get >alist natural-sort [
        first2 value-mapping
    ] map "" concat-as ;

: invert-assoc ( assoc -- inverted )
    V{ } clone [
        [ push-at ] curry assoc-each
    ] keep ;

: congruence-classes ( -- str )
    vregs>vns get invert-assoc >alist natural-sort [
        first2
        natural-sort [ number>string ] map ", " join
        "<%d> : {%s}\\l" sprintf
    ] map "" concat-as ;

: basic-block# ( -- n )
    basic-block get number>> ;

: add-gvns ( graph -- graph' )
    "gvns" add-node[
        gvns congruence-classes "\\l\\l" glue =label
        "plaintext" =shape
    ];
    "gvns" 0 add-edge[ "invis" =style ];
    basic-block# add-node[ "bold" =style ];
    ;

SYMBOL: iteration

: iteration-dir ( -- path )
    iteration get number>string "gvn-iter" prepend ;

: new-iteration ( -- )
    iteration inc iteration-dir make-directories ;

: draw-annotated-cfg ( -- )
    iteration-dir [
        cfg get cfgviz add-gvns
        basic-block# number>string "bb" prepend png
    ] with-directory ;

: annotate-gvn ( -- )
    \ value-numbering-iteration
    [ [ new-iteration ] prepend ] annotate
    \ value-numbering-step
    [ [ draw-annotated-cfg ] append ] annotate ;

: reset-gvn ( -- )
    \ value-numbering-iteration reset
    \ value-numbering-step reset ;

! Replace compiler.cfg.value-numbering:value-numbering with
! compiler.cfg.gvn:value-numbering

: gvn-passes ( -- passes )
    \ optimize-cfg def>> [
        name>> "value-numbering" =
    ] split-when [ value-numbering ] join ;

: test-gvn ( path quot -- )
    gvn-passes passes [
        0 iteration [ watch-optimizer* ] with-variable
    ] with-variable ;

: watch-gvn ( path quot -- )
    annotate-gvn [ test-gvn ] [ reset-gvn ] [ ] cleanup ;
