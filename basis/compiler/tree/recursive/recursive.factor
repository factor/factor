! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel assocs arrays namespaces accessors sequences deques fry
search-deques dlists combinators.short-circuit make sets compiler.tree ;
IN: compiler.tree.recursive

TUPLE: call-site tail? node label ;

: recursive-phi-in ( #enter-recursive -- seq )
    [ label>> calls>> [ node>> in-d>> ] map ] [ in-d>> ] bi suffix ;

<PRIVATE

TUPLE: call-tree-node label children calls ;

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

GENERIC: node-call-tree ( tail? node -- )

: (build-call-tree) ( tail? nodes -- )
    [ tail-calls ] keep
    [ node-call-tree ] 2each ;

: build-call-tree ( nodes -- labels calls )
    [
        V{ } clone children set
        V{ } clone calls set
        [ t ] dip (build-call-tree)
        children get
        calls get
    ] with-scope ;

M: #return-recursive node-call-tree
    nip dup label>> (>>return) ;

M: #call-recursive node-call-tree
    [ dup label>> call-site boa ] keep
    [ drop calls get push ]
    [ label>> calls>> push ] 2bi ;

M: #recursive node-call-tree
    nip
    [ label>> V{ } clone >>calls drop ]
    [
        [ label>> ] [ child>> build-call-tree ] bi
        call-tree-node boa children get push
    ] bi ;

M: #branch node-call-tree
    children>> [ (build-call-tree) ] with each ;

M: node node-call-tree 2drop ;

SYMBOLS: not-loops recursive-nesting ;

: not-a-loop ( label -- ) not-loops get conjoin ;

: not-a-loop? ( label -- ? ) not-loops get key? ;

: non-tail-calls ( call-tree-node -- seq )
    calls>> [ tail?>> not ] filter ;

: visit-back-edges ( call-tree -- )
    [
        [ non-tail-calls [ label>> not-a-loop ] each ]
        [ children>> visit-back-edges ]
        bi
    ] each ;

SYMBOL: changed?

: check-cross-frame-call ( call-site -- )
    label>> dup not-a-loop? [ drop ] [
        recursive-nesting get <reversed> [
            2dup eq? [ 2drop f ] [
                not-a-loop? [ not-a-loop changed? on ] [ drop ] if t
            ] if
        ] with all? drop
    ] if ;

: detect-cross-frame-calls ( call-tree -- )
    ! Suppose we have a nesting of recursives A --> B --> C
    ! B tail-calls A, and C non-tail-calls B. Then A cannot be
    ! a loop, it needs its own procedure, since the call from
    ! C to A crosses a call-frame boundary.
    [
        [ label>> recursive-nesting get push ]
        [ calls>> [ check-cross-frame-call ] each ]
        [ children>> detect-cross-frame-calls ] tri
        recursive-nesting get pop*
    ] each ;

: while-changing ( quot: ( -- ) -- )
    changed? off
    [ call ] [ changed? get [ while-changing ] [ drop ] if ] bi ;
    inline recursive

: detect-loops ( call-tree -- )
    H{ } clone not-loops set
    V{ } clone recursive-nesting set
    [ visit-back-edges ]
    [ '[ _ detect-cross-frame-calls ] while-changing ]
    bi ;

: mark-loops ( call-tree -- )
    [
        [ label>> dup not-a-loop? [ t >>loop? ] unless drop ]
        [ children>> mark-loops ]
        bi
    ] each ;

PRIVATE>

: analyze-recursive ( nodes -- nodes )
    dup build-call-tree drop
    [ detect-loops ] [ mark-loops ] bi ;
