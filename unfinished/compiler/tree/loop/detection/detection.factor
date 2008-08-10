! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel sequences namespaces assocs accessors fry
compiler.tree ;
IN: compiler.tree.loop.detection

! A loop is a #recursive which only tail calls itself, and those
! calls are nested inside other loops only.

TUPLE: recursive-call tail? nesting ;

! calls is a sequence of recursive-call instances
TUPLE: loop-info calls height ;

! Mapping inline-recursive instances to loop-info instances
SYMBOL: loop-infos

! A sequence of inline-recursive instances
SYMBOL: label-stack

: (tail-calls) ( tail? seq -- seq' )
    reverse [ swap [ and ] keep ] map nip reverse ;

: tail-calls ( tail? node -- seq )
    [
        [ #phi? ]
        [ #return? ]
        [ #return-recursive? ]
        tri or or
    ] map (tail-calls) ;

GENERIC: collect-loop-info* ( tail? node -- )

: non-tail-label-info ( nodes -- )
    [ f swap collect-loop-info* ] each ;

: (collect-loop-info) ( tail? nodes -- )
    [ tail-calls ] keep [ collect-loop-info* ] 2each ;

: remember-loop-info ( #recursive -- )
    V{ } clone label-stack get length loop-info boa
    swap label>> loop-infos get set-at ;

M: #recursive collect-loop-info*
    nip
    [
        [ label-stack [ swap label>> suffix ] change ]
        [ remember-loop-info ]
        [ t swap child>> (collect-loop-info) ]
        tri
    ] with-scope ;

M: #call-recursive collect-loop-info*
    label>> loop-infos get at
    [ label-stack get swap height>> tail recursive-call boa ]
    [ calls>> ]
    bi push ;

M: #if collect-loop-info*
    children>> [ (collect-loop-info) ] with each ;

M: #dispatch collect-loop-info*
    children>> [ (collect-loop-info) ] with each ;

M: node collect-loop-info* 2drop ;

: collect-loop-info ( node -- )
    { } label-stack set
    H{ } clone loop-infos set
    t swap (collect-loop-info) ;

! Sub-assoc of loop-infos
SYMBOL: potential-loops

: remove-non-tail-calls ( -- )
    loop-infos get
    [ nip calls>> [ tail?>> ] all? ] assoc-filter
    potential-loops set ;

: (remove-non-loop-calls) ( loop-infos -- )
    f over [
        ! If label X is called from within a label Y that is
        ! no longer a potential loop, then X is no longer a
        ! potential loop either.
        over potential-loops get key? [
            potential-loops get '[ , key? ] all?
            [ drop ] [ potential-loops get delete-at t or ] if
        ] [ 2drop ] if
    ] assoc-each
    [ (remove-non-loop-calls) ] [ drop ] if ;

: remove-non-loop-calls ( -- )
    ! Boolean is set to t if something changed.
    !  We recurse until a fixed point is reached.
    loop-infos get [ calls>> [ nesting>> ] map concat ] assoc-map
    (remove-non-loop-calls) ;

: detect-loops ( nodes -- nodes )
    dup
    collect-loop-info
    remove-non-tail-calls
    remove-non-loop-calls
    potential-loops get [ drop t >>loop? drop ] assoc-each ;
