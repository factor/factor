! Copyright (C) 2007, 2010 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces make sequences io io.files io.pathnames kernel
assocs words vocabs definitions parser continuations hashtables
sorting source-files arrays combinators strings system
math.parser splitting init accessors sets ;
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

SYMBOL: root-cache

root-cache [ H{ } clone ] initialize

ERROR: not-found-in-roots path ;

<PRIVATE

: find-root-for ( path -- path/f )
    vocab-roots get [ prepend-path exists? ] with find nip ;

M: string vocab-path ( string -- path/f )
    dup find-root-for [ prepend-path ] [ not-found-in-roots ] if* ;

PRIVATE>

: vocab-dir ( vocab -- dir )
    vocab-name { { CHAR: . CHAR: / } } substitute ;

: vocab-dir+ ( vocab str/f -- path )
    [ vocab-name "." split ] dip
    [ [ dup last ] dip append suffix ] when*
    "/" join ;

: find-vocab-root ( vocab -- path/f )
    vocab-name dup root-cache get at
    [ ] [ ".factor" vocab-dir+ find-root-for ] ?if ;

: vocab-append-path ( vocab path -- newpath )
    swap find-vocab-root dup [ prepend-path ] [ 2drop f ] if ;

: vocab-source-path ( vocab -- path/f )
    dup ".factor" vocab-dir+ vocab-append-path ;

: vocab-docs-path ( vocab -- path/f )
    dup "-docs.factor" vocab-dir+ vocab-append-path ;

SYMBOL: load-help?

! Defined by vocabs.metadata
SYMBOL: check-vocab-hook

check-vocab-hook [ [ drop ] ] initialize

DEFER: require

<PRIVATE

SYMBOL: require-when-vocabs
require-when-vocabs [ HS{ } clone ] initialize

SYMBOL: require-when-table
require-when-table [ V{ } clone ] initialize

: load-conditional-requires ( vocab -- )
    vocab-name require-when-vocabs get in? [
        require-when-table get [
            [ [ vocab dup [ source-loaded?>> +done+ = ] when ] all? ] dip
            [ require ] curry when
        ] assoc-each
    ] when ;

: load-source ( vocab -- )
    dup check-vocab-hook get call( vocab -- )
    [
        +parsing+ >>source-loaded?
        dup vocab-source-path [ parse-file ] [ [ ] ] if*
        [ +parsing+ >>source-loaded? ] dip
        [ % ] [ call( -- ) ] if-bootstrapping
        +done+ >>source-loaded?
        load-conditional-requires
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
    load-vocab drop ;

: require-when ( if then -- )
    over [ vocab ] all? [
        require drop
    ] [
        [ drop [ require-when-vocabs get adjoin ] each ]
        [ 2array require-when-table get push ] 2bi
    ] if ;

: reload ( name -- )
    dup vocab
    [ [ load-source ] [ load-docs ] bi ]
    [ require ]
    ?if ;

: run ( vocab -- )
    dup load-vocab vocab-main [
        execute( -- )
    ] [
        "The " write vocab-name write
        " vocabulary does not define an entry point." print
        "To define one, refer to \\ MAIN: help" print
    ] ?if ;

SYMBOL: blacklist

<PRIVATE

: add-to-blacklist ( error vocab -- )
    vocab-name blacklist get dup [ set-at ] [ 3drop ] if ;

GENERIC: (load-vocab) ( name -- vocab )

M: vocab (load-vocab)
    [
        dup source-loaded?>> +parsing+ eq? [
            dup source-loaded?>> [ dup load-source ] unless
            dup docs-loaded?>> [ dup load-docs ] unless
        ] unless
    ] [ [ swap add-to-blacklist ] keep rethrow ] recover ;

M: vocab-link (load-vocab)
    vocab-name (load-vocab) ;

M: string (load-vocab) create-vocab (load-vocab) ;

PRIVATE>

[
    dup vocab-name blacklist get at* [ rethrow ] [
        drop dup find-vocab-root
        [ (load-vocab) ] [ dup vocab [ ] [ no-vocab ] ?if ] if
    ] if
] load-vocab-hook set-global

M: vocab-spec where vocab-source-path dup [ 1 2array ] when ;
