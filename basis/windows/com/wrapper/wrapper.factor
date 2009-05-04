USING: alien alien.c-types alien.accessors windows.com.syntax
init windows.com.syntax.private windows.com continuations kernel
namespaces windows.ole32 libc vocabs assocs accessors arrays
sequences quotations combinators math words compiler.units
destructors fry math.parser generalizations sets
specialized-arrays.alien specialized-arrays.direct.alien ;
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
        _ case
        [
            "void*" heap-size * rot <displaced-alien> com-add-ref
            swap 0 set-alien-cell S_OK
        ] [ nip f swap 0 set-alien-cell E_NOINTERFACE ] if*
    ] ;

: (make-add-ref) ( interfaces -- quot )
    length "void*" heap-size * '[
        _
        [ alien-unsigned-4 1+ dup ]
        [ set-alien-unsigned-4 ]
        2bi
    ] ;

: (make-release) ( interfaces -- quot )
    length "void*" heap-size * '[
        _
        [ drop ]
        [ alien-unsigned-4 1- dup ]
        [ set-alien-unsigned-4 ]
        2tri
        dup 0 = [ swap (free-wrapped-object) ] [ nip ] if
    ] ;

: (make-iunknown-methods) ( interfaces -- quots )
    [ (make-query-interface) ]
    [ (make-add-ref) ]
    [ (make-release) ] tri
    3array ;
    
: (thunk) ( n -- quot )
    dup 0 =
    [ drop [ ] ]
    [ "void*" heap-size neg * '[ _ swap <displaced-alien> ] ]
    if ;

: (thunked-quots) ( quots iunknown-methods thunk -- {thunk,quot}s )
    [ '[ @ com-unwrap ] [ swap 2array ] curry map ]
    [                   [ swap 2array ] curry map ] bi-curry bi*
    prepend ;

: compile-alien-callback ( word return parameters abi quot -- word )
    '[ _ _ _ _ alien-callback ]
    [ [ (( -- alien )) define-declared ] pick slip ]
    with-compilation-unit ;

: (callback-word) ( function-name interface-name counter -- word )
    [ "::" rot 3append "-callback-" ] dip number>string 3append
    "windows.com.wrapper.callbacks" create ;

: (finish-thunk) ( param-count thunk quot -- thunked-quot )
    [ [ drop [ ] ] [ swap 1- '[ _ _ ndip ] ] if-empty ]
    dip compose ;

: (make-interface-callbacks) ( interface-name quots iunknown-methods n -- words )
    (thunk) (thunked-quots)
    swap [ find-com-interface-definition family-tree-functions ]
    keep (next-vtbl-counter) '[
        swap [
            [ name>> _ _ (callback-word) ]
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
    [ [ first2 ] 2dip swap (make-interface-callbacks) ]
    curry map-index ;

: (malloc-wrapped-object) ( wrapper -- wrapped-object )
    vtbls>> length "void*" heap-size *
    [ "ulong" heap-size + malloc ] keep
    [ [ 1 ] 2dip set-alien-unsigned-4 ] [ drop ] 2bi ;

: (callbacks>vtbl) ( callbacks -- vtbl )
    [ execute( -- callback ) ] void*-array{ } map-as malloc-byte-array ;
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
    [ over length <direct-void*-array> 0 swap copy ] keep
    [ +wrapped-objects+ get-global set-at ] keep ;
