! Copyright (C) 2007, 2010 Eduardo Cavazos, Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs combinators continuations
definitions io io.files io.pathnames kernel make namespaces
parser sequences sets splitting strings vocabs words ;
IN: vocabs.loader

SYMBOL: vocab-roots

SYMBOL: add-vocab-root-hook

CONSTANT: default-vocab-roots {
    "resource:core"
    "resource:basis"
    "resource:extra"
    "resource:work"
}

STARTUP-HOOK: [
    default-vocab-roots V{ } like vocab-roots set-global
    [ drop ] add-vocab-root-hook set-global
]

: add-vocab-root ( root -- )
    absolute-path trim-tail-separators dup vocab-roots get ?adjoin
    [ add-vocab-root-hook get-global call( root -- ) ] [ drop ] if ;

SYMBOL: root-cache
root-cache [ H{ } clone ] initialize

ERROR: not-found-in-roots path ;

<PRIVATE

: find-root-for ( path -- path/f )
    vocab-roots get [ prepend-path file-exists? ] with find nip ;

: find-root-for-vocab-pathname ( path -- path/f )
    dup find-root-for [ prepend-path ] [ not-found-in-roots ] if* ;

: ensure-parent-directory-is-not-dot ( path -- parent-directory )
    dup parent-directory dup "." =
    [ drop not-found-in-roots ]
    [ nip ] if ;

! If path exists use it, otherwise try to find a vocab that exists
M: string vocab-path
    dup find-root-for [
        prepend-path
    ] [
        {
            { [ dup ?last path-separator? ] [ find-root-for-vocab-pathname ] }
            { [ dup has-file-extension? ] [
                [ ensure-parent-directory-is-not-dot find-root-for-vocab-pathname ]
                [ file-name ] bi append-path
            ] }
            [ find-root-for-vocab-pathname ]
        } cond
    ] if* ;

PRIVATE>

: vocab-dir ( vocab -- dir )
    vocab-name H{ { CHAR: . CHAR: / } } substitute ;

: append-vocab-dir ( vocab str/f -- path )
    [ vocab-name "." split ] dip
    [ [ dup last ] dip append suffix ] when*
    "/" join ;

: find-vocab-root ( vocab -- path/f )
    vocab-name dup ".private" tail? [ drop f ] [
        root-cache get 2dup at [ 2nip ] [
            over ".factor" append-vocab-dir find-root-for
            [ [ -rot set-at ] [ 2drop ] if* ] keep
        ] if*
    ] if ;

: vocab-exists? ( name -- ? )
    [ lookup-vocab ] [ find-vocab-root ] ?unless ;

: vocab-append-path ( vocab path -- newpath )
    swap find-vocab-root [ prepend-path ] [ drop f ] if* ;

: vocab-source-path ( vocab -- path/f )
    vocab-name ".private" ?tail drop
    dup ".factor" append-vocab-dir vocab-append-path ;

: vocab-docs-path ( vocab -- path/f )
    vocab-name ".private" ?tail drop
    dup "-docs.factor" append-vocab-dir vocab-append-path ;

SYMBOL: load-help?

! Defined by vocabs.metadata
SYMBOL: check-vocab-hook
check-vocab-hook [ [ drop ] ] initialize

<PRIVATE

SYMBOL: require-when-vocabs
require-when-vocabs [ HS{ } clone ] initialize

SYMBOL: require-when-table
require-when-table [ V{ } clone ] initialize

: load-conditional-requires ( vocab -- )
    vocab-name require-when-vocabs get in? [
        require-when-table get [
            [ [ lookup-vocab dup [ source-loaded?>> +done+ = ] when ] all? ] dip
            [ require ] curry when
        ] assoc-each
    ] when ;

: load-source ( vocab -- )
    dup check-vocab-hook get call( vocab -- )
    [
        f >>main
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
            dup vocab-docs-path [ ?run-file ] when*
            +done+ >>docs-loaded?
        ] [ ] [ f >>docs-loaded? ] cleanup
    ] when drop ;

PRIVATE>

: require-when ( if then -- )
    over [ lookup-vocab ] all? [
        require drop
    ] [
        [ drop require-when-vocabs get adjoin-all ]
        [ 2array require-when-table get push ] 2bi
    ] if ;

: reload ( name -- )
    dup lookup-vocab [
        f >>source-loaded? f >>docs-loaded? drop
    ] when* require ;

: run ( vocab -- )
    load-vocab
    [ vocab-main ]
    [ execute( -- ) ]
    [
        "The " write vocab-name write
        " vocabulary does not define an entry point." print
        "To define one, refer to \\ MAIN: help" print
    ] ?if ;

<PRIVATE

GENERIC: (require) ( name -- )

M: vocab (require)
    dup source-loaded?>> +parsing+ eq? [
        dup source-loaded?>> [ dup load-source ] unless
        dup docs-loaded?>> [ dup load-docs ] unless
    ] unless drop ;

M: vocab-link (require)
    vocab-name (require) ;

M: string (require)
    dup check-vocab-hook get call( vocab -- )
    create-vocab (require) ;

PRIVATE>

[
    dup find-vocab-root
    [ (require) ]
    [ dup lookup-vocab [ drop ] [ no-vocab ] if ]
    if
] require-hook set-global

M: vocab-spec where vocab-source-path dup [ 1 2array ] when ;

! put here to avoid circularity between vocabs.loader and source-files.errors
{ "source-files.errors" "debugger" } "source-files.errors.debugger" require-when
