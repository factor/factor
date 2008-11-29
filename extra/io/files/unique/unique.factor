! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.bitwise combinators.lib math.parser
random sequences sequences.lib continuations namespaces
io.files io arrays io.files.unique.backend system
combinators vocabs.loader fry ;
IN: io.files.unique

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

: make-unique-file ( prefix suffix -- path )
    temporary-path -rot
    [
        unique-length get random-name swap 3append append-path
        dup (make-unique-file)
    ] 3curry unique-retries get retry ;

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
