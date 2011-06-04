! Copyright (C) 2011 Alex Vondrak.
! See http://factorcode.org/license.txt for BSD license

USING: accessors fry io io.directories io.pathnames
io.streams.string kernel math math.parser namespaces
prettyprint sequences splitting strings tools.annotations

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

: cfgviz ( cfg filename -- cfg )
    over
    <digraph>
        graph[ "t" =labelloc ];
        node[ "box" =shape "Courier" =fontname 10 =fontsize ];
        swap
        [ ?linearize ]
        [ [ add-cfg-vertex ] each-basic-block ]
        [ [ add-cfg-edges ] each-basic-block ]
        tri
    swap png ;

: perform-pass ( cfg pass -- cfg' )
    def>> call( cfg -- cfg' ) ;

: pass-file ( pass pass# -- path )
    [ name>> ] [ number>string "-" append ] bi* prepend ;

: watch-pass ( cfg pass pass# -- cfg' )
    [ drop perform-pass ] 2keep
    pass-file cfgviz ;

: begin-watching-passes ( cfg -- cfg )
    "0-build-cfg" cfgviz ;

: watch-passes ( cfg -- cfg' )
    \ optimize-cfg def>> [ 1 + watch-pass ] each-index ;

: finish-watching-passes ( cfg -- )
    \ finalize-cfg
    \ optimize-cfg def>> length 1 +
    watch-pass drop ;

: watch-cfg ( path cfg -- )
    over make-directories
    [
        [
            begin-watching-passes
            watch-passes
            finish-watching-passes
        ] with-cfg
    ] curry with-directory ;

: watch-cfgs ( path cfgs -- )
    [
        number>string "cfg" prepend append-path
        swap watch-cfg
    ] with each-index ;

: watch-optimizer* ( path quot -- )
    test-builder
    dup length 1 = [ first watch-cfg ] [ watch-cfgs ] if ;

: watch-optimizer ( quot -- )
    [ "" ] dip watch-optimizer* ;
