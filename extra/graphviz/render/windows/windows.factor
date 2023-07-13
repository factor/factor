! Copyright (C) 2012 Alex Vondrak.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit graphviz.render
graphviz.render.private io.directories
io.files.info io.standard-paths io.standard-paths.windows
kernel sequences system ;
IN: graphviz.render.windows

: graphviz-install-directories ( -- directories )
    application-directories [
        directory-entries [
            {
                [ directory? ]
                [ name>> "Graphviz" head? ]
                [ name>> ]
            } 1&&
        ] map sift
    ] map concat ;

M: windows default-graphviz-program ( -- path/f )
    graphviz-install-directories standard-layouts
    [ ".exe" append find-in-applications ] with map sift ?first ;
