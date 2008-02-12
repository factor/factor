! Copyright (C) 2007, 2008 Eduardo Cavazos, Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: namespaces splitting sequences io.files kernel assocs
words vocabs definitions parser continuations inspector debugger
io io.styles io.streams.lines hashtables sorting prettyprint
source-files arrays combinators strings system math.parser
compiler.errors ;
IN: vocabs.loader

SYMBOL: vocab-roots

V{
    "resource:core"
    "resource:extra"
    "resource:work"
} clone vocab-roots set-global

: vocab-dir ( vocab -- dir )
    vocab-name "." split "/" join ;

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
    dup vocab [ vocab-root ] [ find-vocab-root ] ?if ;

M: vocab-link vocab-root
    vocab-link-root ;

: vocab-tests ( vocab -- tests )
    dup vocab-root [
        [
            f >vocab-link dup

            dup "-tests.factor" vocab-dir+ vocab-path+
            dup resource-exists? [ , ] [ drop ] if

            dup vocab-dir "tests" path+ vocab-path+ dup
            ?resource-path directory keys [ ".factor" tail? ] subset
            [ path+ , ] with each
        ] { } make
    ] [ drop f ] if ;

: vocab-files ( vocab -- seq )
    f >vocab-link [
        dup vocab-source-path [ , ] when*
        dup vocab-docs-path [ , ] when*
        vocab-tests %
    ] { } make ;

TUPLE: no-vocab name ;

: no-vocab ( name -- * )
    vocab-name \ no-vocab construct-boa throw ;

M: no-vocab summary drop "Vocabulary does not exist" ;

SYMBOL: load-help?

: source-was-loaded t swap set-vocab-source-loaded? ;

: source-wasn't-loaded f swap set-vocab-source-loaded? ;

: load-source ( vocab-link -- )
    [ source-wasn't-loaded ] keep
    [ vocab-source-path bootstrap-file ] keep
    source-was-loaded ;

: docs-were-loaded t swap set-vocab-docs-loaded? ;

: docs-weren't-loaded f swap set-vocab-docs-loaded? ;

: load-docs ( vocab-link -- )
    load-help? get [
        [ docs-weren't-loaded ] keep
        [ vocab-docs-path ?run-file ] keep
        docs-were-loaded
    ] [ drop ] if ;

: create-vocab-with-root ( vocab-link -- vocab )
    dup vocab-name create-vocab
    swap vocab-root over set-vocab-root ;

: reload ( name -- )
    [
        f >vocab-link
        dup vocab-root [
            dup vocab-source-path resource-exists? [
                create-vocab-with-root
                dup load-source
                load-docs
            ] [ no-vocab ] if
        ] [ no-vocab ] if
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

: modified ( seq quot -- seq )
    [ dup ] swap compose { } map>assoc
    [ nip ] assoc-subset
    [ nip source-modified? ] assoc-subset keys ; inline

: modified-sources ( vocabs -- seq )
    [ vocab-source-path ] modified ;

: modified-docs ( vocabs -- seq )
    [ vocab-docs-path ] modified ;

: update-roots ( vocabs -- )
    [ dup find-vocab-root swap vocab set-vocab-root ] each ;

: to-refresh ( prefix -- modified-sources modified-docs )
    child-vocabs
    dup update-roots
    dup modified-sources swap modified-docs ;

: vocab-heading. ( vocab -- )
    nl
    "==== " write
    dup vocab-name swap vocab write-object ":" print
    nl ;

: load-error. ( triple -- )
    dup first vocab-heading.
    dup second print-error
    drop ;

: load-failures. ( failures -- )
    [ load-error. nl ] each ;

SYMBOL: blacklist

: require-all ( vocabs -- failures )
    [
        V{ } clone blacklist set
        [
            [ require ]
            [ >r vocab-name r> 2array blacklist get push ]
            recover
        ] each
        blacklist get
    ] with-compiler-errors ;

: do-refresh ( modified-sources modified-docs -- )
    2dup
    [ f swap set-vocab-docs-loaded? ] each
    [ f swap set-vocab-source-loaded? ] each
    append prune require-all load-failures. ;

: refresh ( prefix -- ) to-refresh do-refresh ;

: refresh-all ( -- ) "" refresh ;

GENERIC: (load-vocab) ( name -- vocab )
!
M: vocab (load-vocab)
    dup vocab-root [
        dup vocab-source-loaded? [ dup load-source ] unless
        dup vocab-docs-loaded? [ dup load-docs ] unless
    ] when ;

M: string (load-vocab)
    [ ".private" ?tail drop reload ] keep vocab ;

M: vocab-link (load-vocab)
    vocab-name (load-vocab) ;

TUPLE: blacklisted-vocab name ;

: blacklisted-vocab ( name -- * )
    \ blacklisted-vocab construct-boa throw ;

M: blacklisted-vocab error.
    "This vocabulary depends on the " write
    blacklisted-vocab-name write
    " vocabulary which failed to load" print ;

[
    dup vocab-name blacklist get key? [
        vocab-name blacklisted-vocab
    ] [
        [
            dup vocab [ ] [ ] ?if (load-vocab)
        ] with-compiler-errors
    ] if
] load-vocab-hook set-global

: vocab-where ( vocab -- loc )
    vocab-source-path dup [ 1 2array ] when ;

M: vocab where vocab-where ;

M: vocab-link where vocab-where ;
