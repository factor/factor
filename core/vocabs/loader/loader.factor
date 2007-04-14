! Copyright (C) 2007, 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces sequences io.files kernel assocs words vocabs
definitions parser continuations inspector debugger io io.styles
hashtables sorting prettyprint source-files
arrays combinators strings system math.parser compiler.errors
splitting init ;
IN: vocabs.loader

SYMBOL: vocab-roots

V{
    "resource:core"
    "resource:extra"
    "resource:work"
} clone vocab-roots set-global

: vocab-dir ( vocab -- dir )
    vocab-name { { CHAR: . CHAR: / } } substitute ;

: vocab-dir+ ( vocab str/f -- path )
    >r vocab-name "." split r>
    [ >r dup peek r> append add ] when*
    "/" join ;

: vocab-dir? ( root name -- ? )
    over [
        ".factor" vocab-dir+ append-path exists?
    ] [
        2drop f
    ] if ;

SYMBOL: root-cache

H{ } clone root-cache set-global

: find-vocab-root ( vocab -- path/f )
    vocab-name root-cache get [
        vocab-roots get swap [ vocab-dir? ] curry find nip
    ] cache ;

: vocab-append-path ( vocab path -- newpath )
    swap find-vocab-root dup [ prepend-path ] [ 2drop f ] if ;

: vocab-source-path ( vocab -- path/f )
    dup ".factor" vocab-dir+ vocab-append-path ;

: vocab-docs-path ( vocab -- path/f )
    dup "-docs.factor" vocab-dir+ vocab-append-path ;

SYMBOL: load-help?

: source-was-loaded t swap set-vocab-source-loaded? ;

: source-wasn't-loaded f swap set-vocab-source-loaded? ;

: load-source ( vocab -- )
    [ source-wasn't-loaded ] keep
    [ vocab-source-path [ bootstrap-file ] when* ] keep
    source-was-loaded ;

: docs-were-loaded t swap set-vocab-docs-loaded? ;

: docs-weren't-loaded f swap set-vocab-docs-loaded? ;

: load-docs ( vocab -- )
    load-help? get [
        [ docs-weren't-loaded ] keep
        [ vocab-docs-path [ ?run-file ] when* ] keep
        docs-were-loaded
    ] [ drop ] if ;

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
        dup vocab-source-loaded? [ dup load-source ] unless
        dup vocab-docs-loaded? [ dup load-docs ] unless
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
