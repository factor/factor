USING: alien alien.c-types windows.com.syntax init
windows.com.syntax.private windows.com continuations kernel
namespaces windows.ole32 libc vocabs assocs accessors arrays
sequences quotations combinators math words compiler.units
destructors fry math.parser generalizations sets ;
IN: windows.com.wrapper

TUPLE: com-wrapper callbacks vtbls disposed ;

<PRIVATE

SYMBOL: +wrapped-objects+
+wrapped-objects+ get-global
[ H{ } +wrapped-objects+ set-global ]
unless

SYMBOL: +live-wrappers+
+live-wrappers+ get-global
[ V{ } +live-wrappers+ set-global ]
unless

SYMBOL: +vtbl-counter+
+vtbl-counter+ get-global
[ 0 +vtbl-counter+ set-global ]
unless

"windows.com.wrapper.callbacks" create-vocab drop

: (next-vtbl-counter) ( -- n )
    +vtbl-counter+ [ 1+ dup ] change ;

: com-unwrap ( wrapped -- object )
    +wrapped-objects+ get-global at*
    [ "invalid COM wrapping pointer" throw ] unless ;

: (free-wrapped-object) ( wrapped -- )
    [ +wrapped-objects+ get-global delete-at ] keep
    free ;

: (query-interface-cases) ( interfaces -- cases )
    [
        [ find-com-interface-definition family-tree [ iid>> ] map ] dip
        1quotation [ 2array ] curry map
    ] map-index concat
    [ drop f ] suffix ;

: (make-query-interface) ( interfaces -- quot )
    (query-interface-cases) 
    '[
        swap 16 memory>byte-array
        , case
        [
            "void*" heap-size * rot <displaced-alien> com-add-ref
            0 rot set-void*-nth S_OK
        ] [ nip f 0 rot set-void*-nth E_NOINTERFACE ] if*
    ] ;

: (make-add-ref) ( interfaces -- quot )
    length "void*" heap-size * '[
        , swap <displaced-alien>
        0 over ulong-nth
        1+ [ 0 rot set-ulong-nth ] keep
    ] ;

: (make-release) ( interfaces -- quot )
    length "void*" heap-size * '[
        , over <displaced-alien>
        0 over ulong-nth
        1- [ 0 rot set-ulong-nth ] keep
        dup zero? [ swap (free-wrapped-object) ] [ nip ] if
    ] ;

: (make-iunknown-methods) ( interfaces -- quots )
    [ (make-query-interface) ]
    [ (make-add-ref) ]
    [ (make-release) ] tri
    3array ;
    
: (thunk) ( n -- quot )
    dup 0 =
    [ drop [ ] ]
    [ "void*" heap-size neg * '[ , swap <displaced-alien> ] ]
    if ;

: (thunked-quots) ( quots iunknown-methods thunk -- {thunk,quot}s )
    [ '[ , '[ @ com-unwrap ] [ swap 2array ] curry map ] ]
    [ '[ ,                   [ swap 2array ] curry map ] ] bi bi*
    swap append ;

: compile-alien-callback ( word return parameters abi quot -- word )
    '[ , , , , alien-callback ]
    [ [ (( -- alien )) define-declared ] pick slip ]
    with-compilation-unit ;

: byte-array>malloc ( byte-array -- alien )
    [ byte-length malloc ] [ over byte-array>memory ] bi ;

: (callback-word) ( function-name interface-name counter -- word )
    [ "::" rot 3append "-callback-" ] dip number>string 3append
    "windows.com.wrapper.callbacks" create ;

: (finish-thunk) ( param-count thunk quot -- thunked-quot )
    [ [ drop [ ] ] [ swap 1- '[ , , ndip ] ] if-empty ]
    dip compose ;

: (make-interface-callbacks) ( interface-name quots iunknown-methods n -- words )
    (thunk) (thunked-quots)
    swap [ find-com-interface-definition family-tree-functions ]
    keep (next-vtbl-counter) '[
        swap [
            [ name>> , , (callback-word) ]
            [ return>> ] [
                parameters>>
                [ [ first ] map ]
                [ length ] bi
            ] tri
        ] [
            first2 (finish-thunk)
        ] bi*
        "stdcall" swap compile-alien-callback
    ] 2map ;

: (make-callbacks) ( implementations -- sequence )
    dup [ first ] map (make-iunknown-methods)
    [ >r >r first2 r> r> swap (make-interface-callbacks) ]
    curry map-index ;

: (malloc-wrapped-object) ( wrapper -- wrapped-object )
    vtbls>> length "void*" heap-size *
    [ "ulong" heap-size + malloc ] keep
    over <displaced-alien>
    1 0 rot set-ulong-nth ;

: (callbacks>vtbl) ( callbacks -- vtbl )
    [ execute ] map >c-void*-array byte-array>malloc ;
: (callbacks>vtbls) ( callbacks -- vtbls )
    [ (callbacks>vtbl) ] map ;

: (allocate-wrapper) ( wrapper -- )
    dup callbacks>> (callbacks>vtbls) >>vtbls
    f >>disposed drop ;

: (init-hook) ( -- )
    +live-wrappers+ get-global [ (allocate-wrapper) ] each
    H{ } +wrapped-objects+ set-global ;

[ (init-hook) ] "windows.com.wrapper" add-init-hook

PRIVATE>

: allocate-wrapper ( wrapper -- )
    [ (allocate-wrapper) ]
    [ +live-wrappers+ get adjoin ] bi ;

: <com-wrapper> ( implementations -- wrapper )
    (make-callbacks) f f com-wrapper boa
    dup allocate-wrapper ;

M: com-wrapper dispose*
    [ [ free ] each f ] change-vtbls
    +live-wrappers+ get-global delete ;

: com-wrap ( object wrapper -- wrapped-object )
    [ vtbls>> ] [ (malloc-wrapped-object) ] bi
    [ [ set-void*-nth ] curry each-index ] keep
    [ +wrapped-objects+ get-global set-at ] keep ;
