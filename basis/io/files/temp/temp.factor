! (c)2012 Joe Groff bsd license
USING: combinators io.directories io.pathnames kernel
namespaces system vocabs ;
IN: io.files.temp

HOOK: default-temp-directory os ( -- path )

SYMBOL: current-temp-directory

current-temp-directory [
    default-temp-directory dup make-directories
] initialize

: temp-directory ( -- path )
    current-temp-directory get ;

: temp-file ( name -- path )
    temp-directory prepend-path ;

: with-temp-directory ( quot -- )
    [ temp-directory ] dip with-directory ; inline

HOOK: default-cache-directory os ( -- path )

SYMBOL: current-cache-directory

current-cache-directory [
    default-cache-directory dup make-directories
] initialize

: cache-directory ( -- path )
    current-cache-directory get ;

: cache-file ( name -- path )
    cache-directory prepend-path ;

: with-cache-directory ( quot -- )
    [ cache-directory ] dip with-directory ; inline

{
    { [ os windows? ] [ "io.files.temp.windows" ] }
    { [ os macosx? ] [ "io.files.temp.macosx" ] }
    { [ os unix? ] [ "io.files.temp.unix" ] }
} cond require
