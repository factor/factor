USING: io.backend kernel continuations sequences
system vocabs.loader combinators fry ;
IN: io.backend.windows.privileges

HOOK: set-privilege io-backend ( name ? -- )

: with-privileges ( seq quot -- )
    [ '[ _ [ t set-privilege ] each @ ] ]
    [ drop '[ _ [ f set-privilege ] each ] ]
    2bi [ ] cleanup ; inline

{
    { [ os winnt? ] [ "io.backend.windows.nt.privileges" require ] }
    { [ os wince? ] [ "io.backend.windows.ce.privileges" require ] }
} cond
