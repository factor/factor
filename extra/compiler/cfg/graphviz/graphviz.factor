! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license
USING: accessors compiler.cfg.rpo compiler.cfg.dominance
compiler.cfg.dominance.private compiler.cfg.predecessors images.viewer
io io.encodings.ascii io.files io.files.unique io.launcher kernel
math.parser sequences assocs arrays make namespaces ;
IN: compiler.cfg.graphviz

: render-graph ( edges -- )
    "cfg" "dot" make-unique-file
    [
        ascii [
            "digraph CFG {" print
            [ [ number>> number>string ] bi@ " -> " glue write ";" print ] assoc-each
            "}" print
        ] with-file-writer
    ]
    [ { "dot" "-Tpng" "-O" } swap suffix try-process ]
    [ ".png" append { "open" } swap suffix try-process ]
    tri ;

: cfg-edges ( cfg -- edges )
    [
        [
            dup successors>> [
                2array ,
            ] with each
        ] each-basic-block
    ] { } make ;

: render-cfg ( cfg -- ) cfg-edges render-graph ;

: dom-edges ( cfg -- edges )
    [
        compute-predecessors
        compute-dominance
        dom-childrens get [
            [
                2array ,
            ] with each
        ] assoc-each
    ] { } make ;

: render-dom ( cfg -- ) dom-edges render-graph ;