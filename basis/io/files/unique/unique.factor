! Copyright (C) 2008 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: combinators continuations fry io.backend io.directories
io.files io.pathnames kernel locals namespaces random.data
sequences system vocabs ;
IN: io.files.unique

<PRIVATE

HOOK: (touch-unique-file) io-backend ( path -- )

PRIVATE>

: touch-unique-file ( path -- )
    normalize-path (touch-unique-file) ;

SYMBOL: unique-length
SYMBOL: unique-retries

10 unique-length set-global
10 unique-retries set-global

<PRIVATE

: random-file-name ( -- string )
    unique-length get random-string ;

: random-file-name* ( prefix suffix -- string )
    unique-length get random-string glue ;

: retry ( quot: ( -- ? ) n -- )
    <iota> swap [ drop ] prepose attempt-all ; inline

PRIVATE>

: unique-file ( prefix suffix -- path )
    '[
        _ _ random-file-name glue
        dup touch-unique-file
    ] unique-retries get retry absolute-path ;

: unique-files ( prefix suffixes -- paths )
    '[
        V{ } clone [
            _ _ random-file-name '[
                _ glue
                dup touch-unique-file suffix!
            ] with each { } like
        ] [
            [ [ delete-file ] each ] [ rethrow ] bi*
        ] recover
    ] unique-retries get retry [ absolute-path ] map ;

: with-unique-file-writer ( ..a prefix suffix encoding quot -- ..b path )
    [ random-file-name* ] 2dip [ with-file-writer-secure ] keepdd normalize-path ; inline

:: cleanup-unique-file ( ..a prefix suffix quot: ( ..a path -- ..b ) -- ..b )
    prefix suffix unique-file :> path
    [ path quot call ] [ path ?delete-file ] finally ; inline

:: cleanup-unique-files ( ..a prefix suffixes quot: ( ..a paths -- ..b ) -- ..b )
    prefix suffixes unique-files :> paths
    [ paths quot call ] [ paths [ ?delete-file ] each ] finally ; inline

: safe-overwrite-file ( ..a original-path quot: ( ..a empty-path -- ..b ) -- ..b )
    [ "" "" ] dip '[
        [ nip @ ] [ swap move-file-atomically ] 2bi
    ] cleanup-unique-file ; inline

: safe-replace-file ( ..a original-path quot: ( ..a copy-path -- ..b ) -- ..b )
    [ "" "" ] dip '[
        [ copy-file ] [ nip @ ] [ swap move-file-atomically ] 2tri
    ] cleanup-unique-file ; inline

: unique-directory ( -- path )
    [
        random-file-name
        dup make-directory
    ] unique-retries get retry absolute-path ;

:: with-unique-directory ( quot -- path )
    unique-directory :> path
    path quot with-directory
    path ; inline

:: cleanup-unique-directory ( quot -- )
    unique-directory :> path
    [ path quot with-directory ]
    [ path delete-tree ] finally ; inline

{
    { [ os unix? ] [ "io.files.unique.unix" ] }
    { [ os windows? ] [ "io.files.unique.windows" ] }
} cond require
