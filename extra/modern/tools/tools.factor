! Copyright (C) 2019 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: assocs combinators.short-circuit graphviz kernel modern
modern.compiler modern.out modern.slices sequences
sequences.extras ;
IN: modern.tools

: vocabs>using-tool ( vocabs -- assoc )
    [ vocab>literals ] map-zip
    [
        [
            { [ upper-colon? ] [ first "USING:" sequence= ] } 1&&
        ] filter
        [ second >strings ] map
    ] assoc-map ;

! Needs filter-literals
: vocabs>using-tool2 ( vocabs -- assoc )
    [ vocab>literals ] map-zip
    [
      [
        dup { [ upper-colon? ] [ first "USING:" sequence= ] } 1&& [
          second >strings
        ] [
          drop f
        ] if
      ] map-literals harvest concat harvest
    ] assoc-map ;

: vocabs>graph ( vocabs -- graph )
    [ <graph> ] dip vocabs>using-tool2
    [ [ add-edge ] with each ] assoc-each ;