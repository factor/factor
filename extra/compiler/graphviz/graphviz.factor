! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license
USING: accessors compiler.tree.builder compiler.cfg compiler.cfg.rpo
compiler.cfg.dominance compiler.cfg.dominance.private
compiler.cfg.predecessors compiler.cfg.debugger compiler.cfg.optimizer
compiler.cfg.utilities compiler.tree.recursive images.viewer
images.png io io.encodings.ascii io.files io.files.unique io.launcher
kernel math.parser sequences assocs arrays make math namespaces
quotations combinators locals words ;
IN: compiler.graphviz

: quotes ( str -- str' ) "\"" "\"" surround ;

: graph, ( quot title -- )
    [
        quotes "digraph " " {" surround ,
        call
        "}" ,
    ] { } make , ; inline

: render-graph ( quot -- )
    { } make
    "cfg" ".dot" make-unique-file
    dup "Wrote " prepend print
    [ [ concat ] dip ascii set-file-lines ]
    [ { "dot" "-Tpng" "-O" } swap suffix try-process ]
    [ ".png" append "open" swap 2array try-process ]
    tri ; inline

: attrs>string ( seq -- str )
    [ "" ] [ "," join "[" "]" surround ] if-empty ;

: edge,* ( from to attrs -- )
    [
        [ quotes % " -> " % ] [ quotes % " " % ] [ attrs>string % ] tri*
        ";" %
    ] "" make , ;

: edge, ( from to -- )
    { } edge,* ;

: bb-edge, ( from to -- )
    [ number>> number>string ] bi@ edge, ;

: node-style, ( str attrs -- )
    [ [ quotes % " " % ] [ attrs>string % ";" % ] bi* ] "" make , ;

: cfg-title ( cfg/mr -- string )
    [
        "=== word: " %
        [ word>> name>> % ", label: " % ]
        [ label>> name>> % ]
        bi
    ] "" make ;

: cfg-vertex, ( bb -- )
    [ number>> number>string ]
    [ kill-block? { "color=grey" "style=filled" } { } ? ]
    bi node-style, ;

: cfgs ( cfgs -- )
    [
        [
            [ [ cfg-vertex, ] each-basic-block ]
            [
                [
                    dup successors>> [
                        bb-edge,
                    ] with each
                ] each-basic-block
            ] bi
        ] over cfg-title graph,
    ] each ;

: optimized-cfg ( quot -- cfgs )
    {
        { [ dup cfg? ] [ 1array ] }
        { [ dup quotation? ] [ test-cfg [ optimize-cfg ] map ] }
        { [ dup word? ] [ test-cfg [ optimize-cfg ] map ] }
        [ ]
    } cond ;

: render-cfg ( cfg -- )
    optimized-cfg [ cfgs ] render-graph ;

: dom-trees ( cfgs -- )
    [
        [
            needs-dominance drop
            dom-childrens get [
                [
                    bb-edge,
                ] with each
            ] assoc-each
        ] over cfg-title graph,
    ] each ;

: render-dom ( cfg -- )
    optimized-cfg [ dom-trees ] render-graph ;

SYMBOL: word-counts
SYMBOL: vertex-names

: vertex-name ( call-graph-node -- string )
    label>> vertex-names get [
        word>> name>>
        dup word-counts get [ 0 or 1 + dup ] change-at number>string " #" glue
    ] cache ;

: vertex-attrs ( obj -- string )
    tail?>> { "style=bold,label=\"tail\"" } { } ? ;

: call-graph-edge, ( from to attrs -- )
    [ [ vertex-name ] [ vertex-attrs ] bi ] dip append edge,* ;

: (call-graph-back-edges) ( string calls -- )
    [ { "color=red" } call-graph-edge, ] with each ;

: (call-graph-edges) ( string children -- )
    [
        {
            [ { } call-graph-edge, ]
            [ [ vertex-name ] [ label>> loop?>> { "shape=box" } { } ? ] bi node-style, ]
            [ [ vertex-name ] [ calls>> ] bi (call-graph-back-edges) ] 
            [ [ vertex-name ] [ children>> ] bi (call-graph-edges) ]
        } cleave
    ] with each ;

: call-graph-edges ( call-graph-node -- )
    H{ } clone word-counts set
    H{ } clone vertex-names set
    [ "ROOT" ] dip (call-graph-edges) ;

: render-call-graph ( tree -- )
    dup quotation? [ build-tree ] when
    analyze-recursive drop
    [ [ call-graph get call-graph-edges ] "Call graph" graph, ]
    render-graph ;