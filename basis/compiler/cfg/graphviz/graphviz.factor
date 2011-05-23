! Copyright (C) 2011 Alex Vondrak.
! See http://factorcode.org/license.txt for BSD license

USING: accessors fry io io.streams.string kernel math.parser
namespaces prettyprint sequences splitting strings
tools.annotations

compiler.cfg
compiler.cfg.builder
compiler.cfg.debugger
compiler.cfg.linearization
compiler.cfg.finalization
compiler.cfg.optimizer
compiler.cfg.rpo

compiler.cfg.value-numbering
compiler.cfg.value-numbering.graph

graphviz
graphviz.notation
graphviz.render
;
FROM: compiler.cfg.linearization => number-blocks ;
IN: compiler.cfg.graphviz

: left-justify ( str -- str' )
    string-lines "\\l" join ;

: bb-label ( bb -- str )
    [
        instructions>> [ insn. ] each
    ] with-string-writer left-justify ;

: add-cfg-vertex ( graph bb -- graph' )
    [ number>> <node> ]
    [ bb-label =label ]
    [ kill-block?>> [ "grey" =color "filled" =style ] when ]
    tri add ;

: add-cfg-edges ( graph bb -- graph' )
    dup successors>> [
        [ number>> ] bi@ ->
    ] with each ;

SYMBOL: linearize?
linearize? off

: ?linearize ( graph cfg -- graph' )
    linearize? get [
        <anon>
            edge[ "invis" =style ];
            swap linearization-order [ number>> ] map ~->
        add
    ] [ drop ] if ;

SYMBOL: step

: (cfgviz) ( cfg label filename -- )
    [
        <digraph>
            graph[ "t" =labelloc ];
            node[ "box" =shape "Courier" =fontname 10 =fontsize ];
            swap drop ! =label
            swap
            [ ?linearize ]
            [ [ add-cfg-vertex ] each-basic-block ]
            [ [ add-cfg-edges ] each-basic-block ]
            tri
    ] dip png ;

: cfgviz ( cfg pass -- )
    "After " prepend
    step inc step get number>string
    (cfgviz) ;

: (watch-cfgs) ( cfg -- )
    0 step [
        [
            dup "build-cfg" cfgviz
            dup \ optimize-cfg def>> [
                [ def>> call( cfg -- cfg' ) ] keep
                name>> cfgviz
            ] with each
            finalize-cfg "finalize-cfg" cfgviz
        ] with-cfg
    ] with-variable ;

: watch-cfgs ( quot -- )
    test-builder [ (watch-cfgs) ] each ;
