! Copyright (C) 2011 Alex Vondrak.
! See https://factorcode.org/license.txt for BSD license

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
    split-lines "\\l" join ;

: left-justified ( quot -- str )
    with-string-writer left-justify ; inline

: bb-label ( bb -- str )
    [ number>> number>string ]
    [
        [ instructions>> [ insn. ] each ] left-justified
    ] bi "\\n" glue ;

: add-cfg-vertex ( graph bb -- graph' )
    [ number>> <node> ]
    [ bb-label =label ]
    [ kill-block?>> [ "grey" =color "filled" =style ] when ]
    tri add ;

: add-cfg-edges ( graph bb -- graph' )
    dup successors>> [
        [ number>> ] bi@ ->
    ] with each ;

: cfgviz ( cfg -- graph )
    <digraph>
        [graph "t" =labelloc ];
        [node "box" =shape "Courier" =fontname 10 =fontsize ];
        swap [
            [ add-cfg-vertex ] [ add-cfg-edges ] bi
        ] each-basic-block ;

: perform-pass ( cfg pass pass# -- )
    drop def>> call( cfg -- ) ;

: draw-cfg ( cfg pass pass# -- cfg )
    [ dup cfgviz ]
    [ name>> "-" prepend ]
    [ number>string prepend svg ]
    tri* ;

SYMBOL: passes

: watch-pass ( cfg pass pass# -- cfg' )
    [ perform-pass ] 3keep draw-cfg ;

: begin-watching-passes ( cfg -- cfg )
    \ build-cfg 0 draw-cfg ;

: watch-passes ( cfg -- cfg' )
    passes get [ 1 + watch-pass ] each-index ;

: finish-watching-passes ( cfg -- )
    \ finalize-cfg
    passes get length 1 +
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

: ssa. ( quot -- ) test-ssa [ cfgviz preview ] each ;
: flat. ( quot -- ) test-flat [ cfgviz preview ] each ;
: regs. ( quot -- ) test-regs [ cfgviz preview ] each ;
