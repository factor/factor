USING: kernel math math.bitfields combinators.lib math.parser
random sequences sequences.lib continuations namespaces
io.files io.backend io.nonblocking io arrays
io.files.temporary.backend system combinators vocabs.loader ;
IN: io.files.temporary

: random-letter ( -- ch ) 26 random { CHAR: a CHAR: A } random + ;

: random-ch ( -- ch )
    { t f } random [ 10 random CHAR: 0 + ] [ random-letter ] if ;

: random-name ( n -- string ) [ drop random-ch ] "" map-as ;

: <temporary-file> ( prefix suffix -- path duplex-stream )
    temporary-path -rot
    [ 10 random-name swap 3append path+ dup (temporary-file) ] 3curry
    10 retry ;

: with-temporary-file ( quot -- path )
    >r f f <temporary-file> r> with-stream ;

: temporary-directory ( -- path )
    [ temporary-path 10 random-name path+ dup make-directory ] 10 retry ;

: with-temporary-directory ( quot -- )
    >r temporary-directory r>
    [ with-directory ] 2keep drop delete-tree ;

{
    { [ unix? ] [ "io.unix.files.unique" ] }
    { [ windows? ] [ "io.windows.files.unique" ] }
} cond require
