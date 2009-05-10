! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: arrays combinators continuations fry io io.backend
io.directories io.directories.hierarchy io.files io.pathnames
kernel math math.bitwise math.parser namespaces random
sequences system vocabs.loader ;
IN: io.files.unique

HOOK: (touch-unique-file) io-backend ( path -- )
: touch-unique-file ( path -- )
    normalize-path (touch-unique-file) ;

HOOK: default-temporary-directory io-backend ( -- path )

SYMBOL: current-temporary-directory

SYMBOL: unique-length
SYMBOL: unique-retries

10 unique-length set-global
10 unique-retries set-global

: with-temporary-directory ( path quot -- )
    [ current-temporary-directory ] dip with-variable ; inline

<PRIVATE

: random-letter ( -- ch )
    26 random { CHAR: a CHAR: A } random + ;

: random-ch ( -- ch )
    { t f } random
    [ 10 random CHAR: 0 + ] [ random-letter ] if ;

: random-name ( -- string )
    unique-length get [ random-ch ] "" replicate-as ;

: retry ( quot: ( -- ? )  n -- )
    swap [ drop ] prepose attempt-all ; inline

: (make-unique-file) ( path prefix suffix -- path )
    '[
        _ _ _ random-name glue append-path
        dup touch-unique-file
    ] unique-retries get retry ;

PRIVATE>

: make-unique-file ( prefix suffix -- path )
    [ current-temporary-directory get ] 2dip (make-unique-file) ;

: cleanup-unique-file ( prefix suffix quot: ( path -- ) -- )
    [ make-unique-file ] dip [ delete-file ] bi ; inline

: unique-directory ( -- path )
    [
        current-temporary-directory get
        random-name append-path
        dup make-directory
    ] unique-retries get retry ;

: with-unique-directory ( quot -- path )
    [ unique-directory ] dip
    [ with-temporary-directory ] [ drop ] 2bi ; inline

: cleanup-unique-directory ( quot: ( -- ) -- )
    [ unique-directory ] dip
    '[ _ with-temporary-directory ] [ delete-tree ] bi ; inline

: unique-file ( prefix -- path )
    "" make-unique-file ;

{
    { [ os unix? ] [ "io.files.unique.unix" ] }
    { [ os windows? ] [ "io.files.unique.windows" ] }
} cond require

default-temporary-directory current-temporary-directory set-global
