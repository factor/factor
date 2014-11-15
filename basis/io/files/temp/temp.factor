! (c)2012 Joe Groff bsd license
USING: combinators io.directories io.pathnames kernel system
vocabs ;
IN: io.files.temp

HOOK: temp-directory os ( -- path )
HOOK: cache-directory os ( -- path )

: temp-file ( name -- path )
    temp-directory prepend-path ;

: with-temp-directory ( quot -- )
    [ temp-directory ] dip with-directory ; inline

: cache-file ( name -- path )
    cache-directory prepend-path ;

: with-cache-directory ( quot -- )
    [ cache-directory ] dip with-directory ; inline

{
    { [ os windows? ] [ "io.files.temp.windows" ] }
    { [ os macosx? ] [ "io.files.temp.macosx" ] }
    { [ os unix? ] [ "io.files.temp.unix" ] }
} cond require
