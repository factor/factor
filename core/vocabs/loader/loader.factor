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

: vocab-path+ ( vocab path -- newpath )
    swap vocab-root dup [ swap path+ ] [ 2drop f ] if ;

: vocab-source-path ( vocab -- path/f )
    dup ".factor" vocab-dir+ vocab-path+ ;

: vocab-docs-path ( vocab -- path/f )
    dup "-docs.factor" vocab-dir+ vocab-path+ ;

: vocab-dir? ( root name -- ? )
    over [
        ".factor" vocab-dir+ path+ resource-exists?
    ] [
        2drop f
    ] if ;

: find-vocab-root ( vocab -- path/f )
    vocab-roots get swap [ vocab-dir? ] curry find nip ;

M: string vocab-root
    vocab dup [ vocab-root ] when ;

M: vocab-link vocab-root
    vocab-link-root ;

SYMBOL: load-help?

: source-was-loaded t swap set-vocab-source-loaded? ;

: source-wasn't-loaded f swap set-vocab-source-loaded? ;

: load-source ( vocab -- )
    [ source-wasn't-loaded ] keep
    [ vocab-source-path bootstrap-file ] keep
    source-was-loaded ;

: docs-were-loaded t swap set-vocab-docs-loaded? ;

: docs-weren't-loaded f swap set-vocab-docs-loaded? ;

: load-docs ( vocab -- )
    load-help? get [
        [ docs-weren't-loaded ] keep
        [ vocab-docs-path [ ?run-file ] when* ] keep
        docs-were-loaded
    ] [ drop ] if ;

: create-vocab-with-root ( name root -- vocab )
    swap create-vocab [ set-vocab-root ] keep ;

: update-root ( vocab -- )
    dup vocab-root
    [ drop ] [ dup find-vocab-root swap set-vocab-root ] if ;

: reload ( name -- )
    [
        dup vocab [
            dup update-root dup load-source load-docs
        ] [ no-vocab ] ?if
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
    dup update-root

    dup vocab-root [
        [
            dup vocab-source-loaded? [ dup load-source ] unless
            dup vocab-docs-loaded? [ dup load-docs ] unless
        ] [ [ swap add-to-blacklist ] keep rethrow ] recover
    ] when drop ;

M: string (load-vocab)
    ! ".private" ?tail drop
    dup find-vocab-root >vocab-link (load-vocab) ;

M: vocab-link (load-vocab)
    dup vocab-name swap vocab-root dup
    [ create-vocab-with-root (load-vocab) ] [ 2drop ] if ;

[
    [
        dup vocab-name blacklist get at* [
            rethrow
        ] [
            drop
            [ (load-vocab) ] with-compiler-errors
        ] if
    ] with-compiler-errors
] load-vocab-hook set-global

: vocab-where ( vocab -- loc )
    vocab-source-path dup [ 1 2array ] when ;

M: vocab where vocab-where ;

M: vocab-link where vocab-where ;
