! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel math math.bitfields combinators.lib math.parser
random sequences sequences.lib continuations namespaces
io.files io.backend io.nonblocking io arrays
io.files.unique.backend system combinators vocabs.loader ;
IN: io.files.unique

<PRIVATE
: random-letter ( -- ch )
    26 random { CHAR: a CHAR: A } random + ;

: random-ch ( -- ch )
    { t f } random
    [ 10 random CHAR: 0 + ] [ random-letter ] if ;

: random-name ( n -- string )
    [ drop random-ch ] "" map-as ;

: unique-length ( -- n ) 10 ; inline
: unique-retries ( -- n ) 10 ; inline
PRIVATE>

: make-unique-file ( prefix suffix -- path stream )
    temporary-path -rot
    [
        unique-length random-name swap 3append path+
        dup (make-unique-file)
    ] 3curry unique-retries retry ;

: with-unique-file ( quot -- path )
    >r f f make-unique-file r> rot [ with-stream ] dip ; inline

: with-temporary-file ( quot -- )
    with-unique-file delete-file ; inline

: make-unique-directory ( -- path )
    [
        temporary-path unique-length random-name path+
        dup make-directory
    ] unique-retries retry ;

: with-unique-directory ( quot -- path )
    >r make-unique-directory r>
    [ with-directory ] curry keep ; inline

: with-temporary-directory ( quot -- )
    with-unique-directory delete-tree ; inline

{
    { [ unix? ] [ "io.unix.files.unique" ] }
    { [ windows? ] [ "io.windows.files.unique" ] }
} cond require
