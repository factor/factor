! Copyright (C) 2007, 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces sequences io.files kernel assocs words vocabs
definitions parser continuations io hashtables sorting
source-files arrays combinators strings system math.parser
compiler.errors splitting init accessors ;
IN: vocabs.loader

SYMBOL: vocab-roots

V{
    "resource:core"
    "resource:basis"
    "resource:extra"
    "resource:work"
} clone vocab-roots set-global

: vocab-dir ( vocab -- dir )
    vocab-name { { CHAR: . CHAR: / } } substitute ;

: vocab-dir+ ( vocab str/f -- path )
    >r vocab-name "." split r>
    [ >r dup peek r> append suffix ] when*
    "/" join ;

: vocab-dir? ( root name -- ? )
    over [
        ".factor" vocab-dir+ append-path exists?
    ] [
        2drop f
    ] if ;

SYMBOL: root-cache

H{ } clone root-cache set-global

: (find-vocab-root) ( name -- path/f )
    vocab-roots get swap [ vocab-dir? ] curry find nip ;

: find-vocab-root ( vocab -- path/f )
    vocab-name dup root-cache get at [ ] [ (find-vocab-root) ] ?if ;

: vocab-append-path ( vocab path -- newpath )
    swap find-vocab-root dup [ prepend-path ] [ 2drop f ] if ;

: vocab-source-path ( vocab -- path/f )
    dup ".factor" vocab-dir+ vocab-append-path ;

: vocab-docs-path ( vocab -- path/f )
    dup "-docs.factor" vocab-dir+ vocab-append-path ;

SYMBOL: load-help?

: load-source ( vocab -- vocab )
    f >>source-loaded?
    [ vocab-source-path [ parse-file ] [ [ ] ] if* ] keep
    t >>source-loaded?
    [ [ % ] [ call ] if-bootstrapping ] dip ;


: load-docs ( vocab -- vocab )
    load-help? get [
        f >>docs-loaded?
        [ vocab-docs-path [ ?run-file ] when* ] keep
        t >>docs-loaded?
    ] when ;

: reload ( name -- )
    [
        dup vocab [ dup load-source load-docs ] [ no-vocab ] ?if
    ] with-compiler-errors ;

: require ( vocab -- )
    load-vocab drop ;

: run ( vocab -- )
    dup load-vocab vocab-main [
        execute
    ] [
        "The " write vocab-name write
        " vocabulary does not define an entry point." print
        "To define one, refer to \\ MAIN: help" print
    ] ?if ;

SYMBOL: blacklist

: add-to-blacklist ( error vocab -- )
    vocab-name blacklist get dup [ set-at ] [ 3drop ] if ;

GENERIC: (load-vocab) ( name -- )

M: vocab (load-vocab)
    [
        dup vocab-source-loaded? [ load-source ] unless
        dup vocab-docs-loaded? [ load-docs ] unless
        drop
    ] [ [ swap add-to-blacklist ] keep rethrow ] recover ;

M: vocab-link (load-vocab)
    vocab-name create-vocab (load-vocab) ;

M: string (load-vocab)
    create-vocab (load-vocab) ;

[
    [
        dup vocab-name blacklist get at* [
            rethrow
        ] [
            drop
            dup find-vocab-root [
                [ (load-vocab) ] with-compiler-errors
            ] [
                dup vocab [ drop ] [ no-vocab ] if
            ] if
        ] if
    ] with-compiler-errors
] load-vocab-hook set-global

: vocab-where ( vocab -- loc )
    vocab-source-path dup [ 1 2array ] when ;

M: vocab where vocab-where ;

M: vocab-link where vocab-where ;
