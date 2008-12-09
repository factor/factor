! Copyright (C) 2007, 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces make sequences io.files kernel assocs words
vocabs definitions parser continuations io hashtables sorting
source-files arrays combinators strings system math.parser
compiler.errors splitting init accessors sets ;
IN: vocabs.loader

SYMBOL: vocab-roots

V{
    "resource:core"
    "resource:basis"
    "resource:extra"
    "resource:work"
} clone vocab-roots set-global

: add-vocab-root ( root -- )
    vocab-roots get adjoin ;

: vocab-dir ( vocab -- dir )
    vocab-name { { CHAR: . CHAR: / } } substitute ;

: vocab-dir+ ( vocab str/f -- path )
    [ vocab-name "." split ] dip
    [ [ dup peek ] dip append suffix ] when*
    "/" join ;

: vocab-dir? ( root name -- ? )
    over
    [ ".factor" vocab-dir+ append-path exists? ]
    [ 2drop f ]
    if ;

SYMBOL: root-cache

H{ } clone root-cache set-global

<PRIVATE

: (find-vocab-root) ( name -- path/f )
    vocab-roots get swap [ vocab-dir? ] curry find nip ;

PRIVATE>

: find-vocab-root ( vocab -- path/f )
    vocab-name dup root-cache get at [ ] [ (find-vocab-root) ] ?if ;

: vocab-append-path ( vocab path -- newpath )
    swap find-vocab-root dup [ prepend-path ] [ 2drop f ] if ;

: vocab-source-path ( vocab -- path/f )
    dup ".factor" vocab-dir+ vocab-append-path ;

: vocab-docs-path ( vocab -- path/f )
    dup "-docs.factor" vocab-dir+ vocab-append-path ;

SYMBOL: load-help?

ERROR: circular-dependency name ;

<PRIVATE

: load-source ( vocab -- )
    [
        +parsing+ >>source-loaded?
        dup vocab-source-path [ parse-file ] [ [ ] ] if*
        [ +parsing+ >>source-loaded? ] dip
        [ % ] [ assert-depth ] if-bootstrapping
        +done+ >>source-loaded? drop
    ] [ ] [ f >>source-loaded? ] cleanup ;

: load-docs ( vocab -- )
    load-help? get [
        [
            +parsing+ >>docs-loaded?
            [ vocab-docs-path [ ?run-file ] when* ] keep
            +done+ >>docs-loaded?
        ] [ ] [ f >>docs-loaded? ] cleanup
    ] when drop ;

PRIVATE>

: require ( vocab -- )
    [ load-vocab drop ] with-compiler-errors ;

: reload ( name -- )
    dup vocab
    [ [ [ load-source ] [ load-docs ] bi ] with-compiler-errors ]
    [ require ]
    ?if ;

: run ( vocab -- )
    dup load-vocab vocab-main [
        execute
    ] [
        "The " write vocab-name write
        " vocabulary does not define an entry point." print
        "To define one, refer to \\ MAIN: help" print
    ] ?if ;

SYMBOL: blacklist

<PRIVATE

: add-to-blacklist ( error vocab -- )
    vocab-name blacklist get dup [ set-at ] [ 3drop ] if ;

GENERIC: (load-vocab) ( name -- )

M: vocab (load-vocab)
    [
        dup source-loaded?>> +parsing+ eq? [
            dup source-loaded?>> [ dup load-source ] unless
            dup docs-loaded?>> [ dup load-docs ] unless
        ] unless drop
    ] [ [ swap add-to-blacklist ] keep rethrow ] recover ;

M: vocab-link (load-vocab)
    vocab-name create-vocab (load-vocab) ;

M: string (load-vocab)
    create-vocab (load-vocab) ;

[
    [
        dup vocab-name blacklist get at* [ rethrow ] [
            drop dup find-vocab-root
            [ [ (load-vocab) ] with-compiler-errors ]
            [ dup vocab [ drop ] [ no-vocab ] if ]
            if
        ] if
    ] with-compiler-errors
] load-vocab-hook set-global

PRIVATE>

: vocab-where ( vocab -- loc )
    vocab-source-path dup [ 1 2array ] when ;

M: vocab where vocab-where ;

M: vocab-link where vocab-where ;
