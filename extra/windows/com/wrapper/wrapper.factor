USING: alien alien.c-types windows.com.syntax
windows.com.syntax.private windows.com continuations kernel
sequences.lib namespaces windows.ole32 libc
assocs accessors arrays sequences quotations combinators
math combinators.lib words compiler.units ;
IN: windows.com.wrapper

TUPLE: com-wrapper vtbls freed? ;

<PRIVATE

SYMBOL: +wrapped-objects+
+wrapped-objects+ get-global
[ H{ } +wrapped-objects+ set-global ]
unless

: com-unwrap ( wrapped -- object )
    +wrapped-objects+ get-global at*
    [ "invalid COM wrapping pointer" throw ] unless ;

: (free-wrapped-object) ( wrapped -- )
    [ +wrapped-objects+ get-global delete-at ] keep
    free ;

: (make-query-interface) ( interfaces -- quot )
    [
        [ swap 16 memory>byte-array ] %
        [
            >r find-com-interface-definition family-tree
            r> 1quotation [ >r iid>> r> 2array ] curry map
        ] map-index concat
        [ f ] add ,
        \ case ,
        "void*" heap-size
        [ * rot <displaced-alien> com-add-ref 0 rot set-void*-nth S_OK ]
        curry ,
        [ nip f 0 rot set-void*-nth E_NOINTERFACE ] ,
        \ if* ,
    ] [ ] make ;

: (make-add-ref) ( interfaces -- quot )
    length "void*" heap-size * [ swap <displaced-alien>
        0 over ulong-nth
        1+ [ 0 rot set-ulong-nth ] keep
    ] curry ;

: (make-release) ( interfaces -- quot )
    length "void*" heap-size * [ over <displaced-alien>
        0 over ulong-nth
        1- [ 0 rot set-ulong-nth ] keep
        dup zero? [ swap (free-wrapped-object) ] [ nip ] if
    ] curry ;

: (make-iunknown-methods) ( interfaces -- quots )
    [ (make-query-interface) ]
    [ (make-add-ref) ]
    [ (make-release) ] tri
    3array ;
    
: (thunk) ( n -- quot )
    dup 0 =
    [ drop [ ] ]
    [ "void*" heap-size neg * [ swap <displaced-alien> ] curry ]
    if ;

: (thunked-quots) ( quots iunknown-methods thunk -- quots' )
    [ [ swap 2array ] curry map swap ] keep
    [ com-unwrap ] compose [ swap 2array ] curry map append ;

: compile-alien-callback ( return parameters abi quot -- alien )
    [ alien-callback ] 4 ncurry
    [ gensym [ swap define ] keep ] with-compilation-unit
    execute ;

: (make-vtbl) ( interface-name quots iunknown-methods n -- )
    (thunk) (thunked-quots)
    swap find-com-interface-definition family-tree-functions [
        { return>> parameters>> } get-slots
        dup length 1- roll [
            first dup empty?
            [ 2drop [ ] ]
            [ swap [ ndip ] 2curry ]
            if
        ] [ second ] bi compose
        "stdcall" swap compile-alien-callback
    ] 2map >c-void*-array [ byte-length malloc ] keep
    over byte-array>memory ;

: (make-vtbls) ( implementations -- vtbls )
    dup [ first ] map (make-iunknown-methods)
    [ >r >r first2 r> r> swap (make-vtbl) ] curry map-index ;

: (malloc-wrapped-object) ( wrapper -- wrapped-object )
    vtbls>> length "void*" heap-size *
    [ "ulong" heap-size + malloc ] keep
    over <displaced-alien>
    1 0 rot set-ulong-nth ;

PRIVATE>

: <com-wrapper> ( implementations -- wrapper )
    (make-vtbls) f com-wrapper construct-boa ;

M: com-wrapper dispose
    t >>freed?
    vtbls>> [ free ] each ;

: com-wrap ( object wrapper -- wrapped-object )
    dup (malloc-wrapped-object) >r vtbls>> r>
    [ [ set-void*-nth ] curry each-index ] keep
    [ +wrapped-objects+ get-global set-at ] keep ;
