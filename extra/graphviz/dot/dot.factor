! Copyright (C) 2012 Alex Vondrak.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors classes classes.tuple combinators formatting
graphviz graphviz.attributes io io.files kernel namespaces
sequences splitting strings words ;
IN: graphviz.dot

<PRIVATE

GENERIC: dot. ( obj -- )

! Graphviz docs claim that there's no semantic difference
! between quoted & unquoted IDs, but quoting them is the safest
! option in case there's a keyword clash, spaces in the ID,
! etc.  This does mean that HTML labels aren't supported, but
! they don't seem to work using the Graphviz API anyway.
: escape ( str -- str' )
    "\"" split "\\\"" join
    "\0" split "" join ;

M: string dot. escape "\"%s\" " printf ;

: id. ( obj -- ) id>> dot. ;

M: sequence dot.
    "{" print [ dot. ";" print ] each "}" print ;

: statements. ( sub/graph -- ) statements>> dot. ;

SYMBOL: edgeop

: with-edgeop ( graph quot -- )
    [
        dup directed?>> "-> " "-- " ? edgeop
    ] dip with-variable ; inline

: ?strict ( graph -- graph )
    dup strict?>> [ "strict " write ] when ;

: (di)graph ( graph -- graph )
    dup directed?>> "digraph " "graph " ? write ;

M: graph dot.
    ?strict (di)graph dup id. [ statements. ] with-edgeop ;

M: subgraph dot.
    "subgraph " write [ id. ] [ statements. ] bi ;

: attribute, ( attr value -- )
    dup [ "%s=\"%s\"," printf ] [ 2drop ] if ;

: attributes. ( attrs -- )
    "[" write
    [ class-of "slots" word-prop ] [ tuple>array rest ] bi
    [ [ name>> ] dip attribute, ] 2each
    "]" write ;

M: graph-attributes dot. "graph" write attributes. ;
M: node-attributes dot. "node" write attributes. ;
M: edge-attributes dot. "edge" write attributes. ;

M: node dot.
    [ id. ] [ attributes>> attributes. ] bi ;

M: edge dot.
    {
        [ tail>> dot. ]
        [ drop edgeop get write ]
        [ head>> dot. ]
        [ attributes>> attributes. ]
    } cleave ;

PRIVATE>

: write-dot ( graph path encoding -- )
    [ dot. ] with-file-writer ;
