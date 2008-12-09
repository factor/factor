! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.bitwise math.parser random sequences
continuations namespaces io.files io arrays system
combinators vocabs.loader fry io.backend ;
IN: io.files.unique

HOOK: touch-unique-file io-backend ( path -- )
HOOK: temporary-path io-backend ( -- path )

SYMBOL: unique-length
SYMBOL: unique-retries

10 unique-length set-global
10 unique-retries set-global

<PRIVATE

: random-letter ( -- ch )
    26 random { CHAR: a CHAR: A } random + ;

: random-ch ( -- ch )
    { t f } random
    [ 10 random CHAR: 0 + ] [ random-letter ] if ;

: random-name ( n -- string )
    [ random-ch ] "" replicate-as ;

PRIVATE>

: (make-unique-file) ( path prefix suffix -- path )
    '[
        _ _ _ unique-length get random-name glue append-path
        dup touch-unique-file
    ] unique-retries get retry ;

: make-unique-file ( prefix suffix -- path )
    [ temporary-path ] 2dip (make-unique-file) ;

: make-unique-file* ( prefix suffix -- path )
    [ current-directory get ] 2dip (make-unique-file) ;

: with-unique-file ( prefix suffix quot: ( path -- ) -- )
    [ make-unique-file ] dip [ delete-file ] bi ; inline

: make-unique-directory ( -- path )
    [
        temporary-path unique-length get random-name append-path
        dup make-directory
    ] unique-retries get retry ;

: with-unique-directory ( quot: ( -- ) -- )
    [ make-unique-directory ] dip
    '[ _ with-directory ] [ delete-tree ] bi ; inline

{
    { [ os unix? ] [ "io.unix.files.unique" ] }
    { [ os windows? ] [ "io.windows.files.unique" ] }
} cond require
