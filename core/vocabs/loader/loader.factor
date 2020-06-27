! Copyright (C) 2007, 2010 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs continuations definitions
hashtables init io io.files io.pathnames kernel make namespaces
parser sequences sets splitting strings system vocabs words ;
IN: vocabs.loader

SYMBOL: add-vocab-root-hook

CONSTANT: default-vocab-roots {
    "resource:core"
    "resource:basis"
    "resource:extra"
    "resource:work"
}

[
    default-vocab-roots V{ } like vocab-roots set-global

    [ drop ] add-vocab-root-hook set-global
] "vocabs.loader" add-startup-hook

: add-vocab-root ( root -- )
    trim-tail-separators dup vocab-roots get ?adjoin
    [ add-vocab-root-hook get-global call( root -- ) ] [ drop ] if ;

ERROR: not-found-in-roots path ;

<PRIVATE

: find-root-for ( path -- path/f )
    vocab-roots get [ prepend-path exists? ] with find nip ;

M: string vocab-path ( string -- path/f )
    "vocab:" ?head drop
    dup find-root-for [ prepend-path ] [ not-found-in-roots ] if* ;

PRIVATE>

: vocab-dir ( vocab -- dir )
    vocab-name H{ { CHAR: . CHAR: / } } substitute ;

: append-vocab-dir ( vocab str/f -- path )
    [ vocab-name "." split ] dip
    [ [ dup last ] dip append suffix ] when*
    "/" join ;

: find-vocab-root ( vocab -- path/f )
    vocab-name root-cache get [
        dup "+private" tail? [ drop f ] [
            ".factor" append-vocab-dir find-root-for
        ] if
    ] cache ;

: vocab-exists? ( name -- ? )
    dup lookup-vocab [ ] [ find-vocab-root ] ?if ;

: vocab-append-path ( vocab path -- newpath )
    swap find-vocab-root [ prepend-path ] [ drop f ] if* ;

: vocab-source-path ( vocab -- path/f )
    dup ".factor" append-vocab-dir vocab-append-path ;

: vocab-docs-path ( vocab -- path/f )
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
    dup lookup-vocab
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

: require-all ( vocabs -- )
    V{ } clone blacklist [ [ require ] each ] with-variable ;

<PRIVATE

: add-to-blacklist ( error vocab -- )
    vocab-name blacklist get [ set-at ] [ 2drop ] if* ;

GENERIC: (require) ( name -- )

M: vocab (require)
    [
        dup source-loaded?>> +parsing+ eq? [ drop ] [
            dup source-loaded?>> [ dup load-source ] unless
            dup docs-loaded?>> [ dup load-docs ] unless
            drop
        ] if
    ] [ [ swap add-to-blacklist ] keep rethrow ] recover ;

M: vocab-link (require)
    vocab-name (require) ;

M: string (require)
    dup check-vocab-hook get call( vocab -- )
    create-vocab (require) ;

PRIVATE>

[
    dup vocab-name blacklist get at*
    [ rethrow ]
    [
        drop dup find-vocab-root
        [ (require) ]
        [ dup lookup-vocab [ drop ] [ no-vocab ] if ]
        if
    ] if
] require-hook set-global

M: vocab-spec where vocab-source-path dup [ 1 2array ] when ;




ERROR: not-a-vocab-root string ;

: vocab-root? ( string -- ? )
    trim-tail-separators vocab-roots get member? ;

: check-root ( string -- string )
    dup vocab-root? [ not-a-vocab-root ] unless ;

: check-vocab-root/vocab ( vocab-root string -- vocab-root string )
    [ check-root ] [ check-vocab-name ] bi* ;

: replace-vocab-separators ( vocab -- path )
    path-separator first CHAR: . associate substitute ;

: vocab-root/vocab>path ( vocab-root vocab -- path )
    check-vocab-root/vocab
    [ ] [ replace-vocab-separators ] bi* append-path ;

: vocab>path ( vocab -- path )
    ! check-vocab
    [ find-vocab-root ] keep vocab-root/vocab>path ;

: ?vocab>path ( vocab -- path )
    ! check-vocab
    [ find-vocab-root ] keep
    over [ vocab-root/vocab>path ] [ 2drop f ] if ;

: vocab-entries ( vocab -- entries )
    vocab>path qualified-directory-entries ;

: ?vocab-entries ( vocab -- entries )
    ?vocab>path [ qualified-directory-entries ] [ { } ] if* ;

: vocab-name-last ( vocab-name -- last )
    vocab-name "." split1-last swap or ;

: vocab-section-paths ( vocab -- paths )
    [
        ?vocab-entries
        [ type>> +regular-file+ = ] filter
        [ name>> ] map
        [ ".factor" tail? ] filter
    ] [ vocab-name-last ] bi
    [ head? ] curry
    [ file-stem ] prepose filter ;

: vocab/stem>sections ( vocab stem -- sections )
    ?head drop "-" ?head drop "," split harvest ;



! put here to avoid circularity between vocabs.loader and source-files.errors
{ "source-files.errors" "debugger" } "source-files.errors.debugger" require-when
