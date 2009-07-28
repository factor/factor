! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license
USING: accessors compiler.cfg.rpo images.viewer io
io.encodings.ascii io.files io.files.unique io.launcher kernel
math.parser sequences ;
IN: compiler.cfg.graphviz

: cfg>dot ( cfg -- )
    "digraph CFG {" print
    [
        [ number>> ] [ successors>> ] bi [
            number>> [ number>string ] bi@ " -> " glue write ";" print
        ] with each
    ] each-basic-block
    "}" print ;

: render-cfg ( cfg -- )
    "cfg" "dot" make-unique-file
    [ ascii [ cfg>dot ] with-file-writer ]
    [ { "dot" "-Tpng" "-O" } swap suffix try-process ]
    [ ".png" append { "open" } swap suffix try-process ]
    tri ;
