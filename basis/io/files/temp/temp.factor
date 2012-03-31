! (c)2012 Joe Groff bsd license
USING: combinators io.pathnames kernel system vocabs ;
IN: io.files.temp

HOOK: temp-directory os ( -- path )
HOOK: cache-directory os ( -- path )

: temp-file ( name -- path )
    temp-directory prepend-path ;

: cache-file ( name -- path )
    cache-directory prepend-path ;

{
    { [ os windows? ] [ "io.files.temp.windows" ] }
    { [ os macosx? ] [ "io.files.temp.macosx" ] }
    { [ os unix? ] [ "io.files.temp.unix" ] }
    [ "unknown io.files.temp platform" throw ]
} cond require
