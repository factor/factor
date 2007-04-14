! Copyright (C) 2007, 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: io.files kernel io.encodings.utf8 vocabs.loader vocabs
sequences namespaces math.parser arrays hashtables assocs
memoize inspector sorting splitting combinators source-files
io debugger continuations compiler.errors init io.crc32 ;
IN: tools.vocabs

: vocab-tests-file ( vocab -- path )
    dup "-tests.factor" vocab-dir+ vocab-append-path dup
    [ dup exists? [ drop f ] unless ] [ drop f ] if ;

: vocab-tests-dir ( vocab -- paths )
    dup vocab-dir "tests" append-path vocab-append-path dup [
        dup exists? [
            dup directory keys
            [ ".factor" tail? ] subset
            [ append-path ] with map
        ] [ drop f ] if
    ] [ drop f ] if ;

: vocab-tests ( vocab -- tests )
    [
        dup vocab-tests-file [ , ] when*
        vocab-tests-dir [ % ] when*
    ] { } make ;

: vocab-files ( vocab -- seq )
    [
        dup vocab-source-path [ , ] when*
        dup vocab-docs-path [ , ] when*
        vocab-tests %
    ] { } make ;

: source-modified? ( path -- ? )
    dup source-files get at [
        dup source-file-path
        dup exists? [
            utf8 file-lines lines-crc32
            swap source-file-checksum = not
        ] [
            2drop f
        ] if
    ] [
        exists?
    ] ?if ;

: modified ( seq quot -- seq )
    [ dup ] swap compose { } map>assoc
    [ nip ] assoc-subset
    [ nip source-modified? ] assoc-subset keys ; inline

: modified-sources ( vocabs -- seq )
    [ vocab-source-path ] modified ;

: modified-docs ( vocabs -- seq )
    [ vocab-docs-path ] modified ;

: to-refresh ( prefix -- modified-sources modified-docs )
    child-vocabs
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

SYMBOL: failures

: require-all ( vocabs -- failures )
    [
        V{ } clone blacklist set
        V{ } clone failures set
        [
            [ require ]
            [ swap vocab-name failures get set-at ]
            recover
        ] each
        failures get
    ] with-compiler-errors ;

: do-refresh ( modified-sources modified-docs -- )
    2dup
    [ f swap set-vocab-docs-loaded? ] each
    [ f swap set-vocab-source-loaded? ] each
    append prune require-all load-failures. ;

: refresh ( prefix -- ) to-refresh do-refresh ;

SYMBOL: sources-changed?

[ t sources-changed? set-global ] "tools.vocabs" add-init-hook

: refresh-all ( -- )
    "" refresh f sources-changed? set-global ;

MEMO: (vocab-file-contents) ( path -- lines )
    dup exists? [ utf8 file-lines ] [ drop f ] if ;

: vocab-file-contents ( vocab name -- seq )
    vocab-append-path dup [ (vocab-file-contents) ] when ;

: set-vocab-file-contents ( seq vocab name -- )
    dupd vocab-append-path [
        utf8 set-file-lines
        \ (vocab-file-contents) reset-memoized
    ] [
        "The " swap vocab-name
        " vocabulary was not loaded from the file system"
        3append throw
    ] ?if ;

: vocab-summary-path ( vocab -- string )
    vocab-dir "summary.txt" append-path ;

: vocab-summary ( vocab -- summary )
    dup dup vocab-summary-path vocab-file-contents
    dup empty? [
        drop vocab-name " vocabulary" append
    ] [
        nip first
    ] if ;

M: vocab summary
    [
        dup vocab-summary %
        " (" %
        vocab-words assoc-size #
        " words)" %
    ] "" make ;

M: vocab-link summary vocab-summary ;

: set-vocab-summary ( string vocab -- )
    >r 1array r>
    dup vocab-summary-path
    set-vocab-file-contents ;

: vocab-tags-path ( vocab -- string )
    vocab-dir "tags.txt" append-path ;

: vocab-tags ( vocab -- tags )
    dup vocab-tags-path vocab-file-contents ;

: set-vocab-tags ( tags vocab -- )
    dup vocab-tags-path set-vocab-file-contents ;

: add-vocab-tags ( tags vocab -- )
    [ vocab-tags append prune ] keep set-vocab-tags ;

: vocab-authors-path ( vocab -- string )
    vocab-dir "authors.txt" append-path ;

: vocab-authors ( vocab -- authors )
    dup vocab-authors-path vocab-file-contents ;

: set-vocab-authors ( authors vocab -- )
    dup vocab-authors-path set-vocab-file-contents ;

: subdirs ( dir -- dirs )
    directory [ second ] subset keys natural-sort ;

: (all-child-vocabs) ( root name -- vocabs )
    [ vocab-dir append-path subdirs ] keep
    dup empty? [
        drop
    ] [
        swap [ "." swap 3append ] with map
    ] if ;

: vocabs-in-dir ( root name -- )
    dupd (all-child-vocabs) [
        2dup vocab-dir? [ dup >vocab-link , ] when
        vocabs-in-dir
    ] with each ;

: all-vocabs ( -- assoc )
    vocab-roots get [
        dup [ "" vocabs-in-dir ] { } make
    ] { } map>assoc ;

MEMO: all-vocabs-seq ( -- seq )
    all-vocabs values concat ;

: dangerous? ( name -- ? )
    #! Hack
    {
        { [ "cpu." ?head ] [ t ] }
        { [ "io.unix" ?head ] [ t ] }
        { [ "io.windows" ?head ] [ t ] }
        { [ "ui.x11" ?head ] [ t ] }
        { [ "ui.windows" ?head ] [ t ] }
        { [ "ui.cocoa" ?head ] [ t ] }
        { [ "cocoa" ?head ] [ t ] }
        { [ "core-foundation" ?head ] [ t ] }
        { [ "vocabs.loader.test" ?head ] [ t ] }
        { [ "editors." ?head ] [ t ] }
        { [ ".windows" ?tail ] [ t ] }
        { [ ".unix" ?tail ] [ t ] }
        { [ "unix." ?head ] [ t ] }
        { [ ".linux" ?tail ] [ t ] }
        { [ ".bsd" ?tail ] [ t ] }
        { [ ".macosx" ?tail ] [ t ] }
        { [ "windows." ?head ] [ t ] }
        { [ "cocoa" ?head ] [ t ] }
        { [ ".test" ?tail ] [ t ] }
        { [ "raptor" ?head ] [ t ] }
        { [ dup "tools.deploy.app" = ] [ t ] }
        { [ t ] [ f ] }
    } cond nip ;

: filter-dangerous ( seq -- seq' )
    [ vocab-name dangerous? not ] subset ;

: try-everything ( -- failures )
    all-vocabs-seq
    filter-dangerous
    require-all ;

: load-everything ( -- )
    try-everything load-failures. ;

: unrooted-child-vocabs ( prefix -- seq )
    dup empty? [ CHAR: . add ] unless
    vocabs
    [ find-vocab-root not ] subset
    [
        vocab-name swap ?head CHAR: . rot member? not and
    ] with subset
    [ vocab ] map ;

: all-child-vocabs ( prefix -- assoc )
    vocab-roots get [
        dup pick (all-child-vocabs) [ >vocab-link ] map
    ] { } map>assoc
    swap unrooted-child-vocabs f swap 2array add ;

: all-child-vocabs-seq ( prefix -- assoc )
    vocab-roots get swap [
        dupd (all-child-vocabs)
        [ vocab-dir? ] with subset
    ] curry map concat ;

: map>set ( seq quot -- )
    map concat prune natural-sort ; inline

MEMO: all-tags ( -- seq )
    all-vocabs-seq [ vocab-tags ] map>set ;

MEMO: all-authors ( -- seq )
    all-vocabs-seq [ vocab-authors ] map>set ;

: reset-cache ( -- )
    root-cache get-global clear-assoc
    \ (vocab-file-contents) reset-memoized
    \ all-vocabs-seq reset-memoized
    \ all-authors reset-memoized
    \ all-tags reset-memoized ;
