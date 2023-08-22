! Copyright (C) 2008, 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors combinators.short-circuit compiler.tree fry
kernel namespaces sequences sets ;
IN: compiler.tree.recursive

TUPLE: call-site tail? node label ;

: recursive-phi-in ( #enter-recursive -- seq )
    [ label>> calls>> [ node>> in-d>> ] map ] [ in-d>> ] bi suffix ;

<PRIVATE

TUPLE: call-graph-node tail? label children calls ;

: (tail-calls) ( tail? seq -- seq' )
    reverse [ swap [ and ] keep ] map nip reverse ;

: tail-calls ( tail? node -- seq )
    [
        {
            [ #phi? ]
            [ #return? ]
            [ #return-recursive? ]
        } 1||
    ] map (tail-calls) ;

SYMBOLS: children calls ;

GENERIC: node-call-graph ( tail? node -- )

: (build-call-graph) ( tail? nodes -- )
    [ tail-calls ] keep
    [ node-call-graph ] 2each ;

: build-call-graph ( nodes -- labels calls )
    [
        V{ } clone children namespaces:set
        V{ } clone calls namespaces:set
        [ t ] dip (build-call-graph)
        children get
        calls get
    ] with-scope ;

M: #return-recursive node-call-graph
    nip dup label>> return<< ;

M: #call-recursive node-call-graph
    [ dup label>> call-site boa ] keep
    [ drop calls get push ]
    [ label>> calls>> push ] 2bi ;

M: #recursive node-call-graph
    [ label>> V{ } clone >>calls drop ]
    [
        [ label>> ] [ child>> build-call-graph ] bi
        call-graph-node boa children get push
    ] bi ;

M: #branch node-call-graph
    children>> [ (build-call-graph) ] with each ;

M: #alien-callback node-call-graph
    child>> (build-call-graph) ;

M: node node-call-graph 2drop ;

SYMBOLS: not-loops recursive-nesting ;

: not-a-loop ( label -- ) not-loops get adjoin ;

: not-a-loop? ( label -- ? ) not-loops get in? ;

: non-tail-calls ( call-graph-node -- seq )
    calls>> [ tail?>> ] reject ;

: visit-back-edges ( call-graph -- )
    [
        [ non-tail-calls [ label>> not-a-loop ] each ]
        [ children>> visit-back-edges ]
        bi
    ] each ;

SYMBOL: changed?

: check-cross-frame-call ( call-site -- )
    label>> dup not-a-loop? [ drop ] [
        recursive-nesting get <reversed> [
            2dup label>> eq? [ 2drop f ] [
                { [ label>> not-a-loop? ] [ tail?>> not ] } 1||
                [ not-a-loop changed? on ] [ drop ] if t
            ] if
        ] with all? drop
    ] if ;

: detect-cross-frame-calls ( call-graph -- )
    ! Suppose we have a nesting of recursives A --> B --> C
    ! B tail-calls A, and C non-tail-calls B. Then A cannot be
    ! a loop, it needs its own procedure, since the call from
    ! C to A crosses a call-frame boundary.
    [
        [ recursive-nesting get push ]
        [ calls>> [ check-cross-frame-call ] each ]
        [ children>> detect-cross-frame-calls ] tri
        recursive-nesting get pop*
    ] each ;

: while-changing ( ... quot: ( ... -- ... ) -- ... )
    changed? off
    [ call ]
    [ changed? get [ while-changing ] [ drop ] if ] bi ; inline recursive

: detect-loops ( call-graph -- )
    HS{ } clone not-loops namespaces:set
    V{ } clone recursive-nesting namespaces:set
    [ visit-back-edges ]
    [ '[ _ detect-cross-frame-calls ] while-changing ]
    bi ;

: mark-loops ( call-graph -- )
    [
        [ label>> dup not-a-loop? [ t >>loop? ] unless drop ]
        [ children>> mark-loops ]
        bi
    ] each ;

PRIVATE>

SYMBOL: call-graph

: analyze-recursive ( nodes -- nodes )
    dup build-call-graph drop
    [ call-graph namespaces:set ]
    [ detect-loops ]
    [ mark-loops ]
    tri ;
