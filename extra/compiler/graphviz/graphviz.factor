! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license
USING: accessors arrays assocs combinators compiler.cfg
compiler.cfg.debugger compiler.cfg.dominance
compiler.cfg.dominance.private compiler.cfg.rpo
compiler.tree.builder compiler.tree.recursive graphviz.render io
io.encodings.ascii io.files io.files.unique io.launcher kernel
make math math.parser namespaces quotations sequences words ;
FROM: assocs => change-at ;
IN: compiler.graphviz

: quotes ( str -- str' ) "\"" "\"" surround ;

: graph, ( quot title -- )
    [
        quotes "digraph " " {" surround ,
        call
        "}" ,
    ] { } make , ; inline

: render-graph ( quot -- name )
    { } make
    "cfg" ".dot" make-unique-file
    dup "Wrote " prepend print
    [ [ concat ] dip ascii set-file-lines ]
    [ [ ?default-graphviz-program "-Tpng" "-O" ] dip 4array try-process ]
    [ ".png" append ]
    tri ; inline

: display-graph ( name -- )
    "open" swap 2array try-process ;

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
    [ kill-block?>> { "color=grey" "style=filled" } { } ? ]
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
        { [ dup quotation? ] [ test-ssa ] }
        { [ dup word? ] [ test-ssa ] }
        [ ]
    } cond ;

: render-cfg ( cfg -- name )
    optimized-cfg [ cfgs ] render-graph ;

: dom-trees ( cfgs -- )
    [
        [
            needs-dominance
            dom-childrens get [
                [
                    bb-edge,
                ] with each
            ] assoc-each
        ] over cfg-title graph,
    ] each ;

: render-dom ( cfg -- name )
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

: render-call-graph ( tree -- name )
    dup quotation? [ build-tree ] when
    analyze-recursive drop
    [ [ call-graph get call-graph-edges ] "Call graph" graph, ]
    render-graph ;
