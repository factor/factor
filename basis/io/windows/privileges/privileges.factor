USING: io.backend kernel continuations sequences
system vocabs.loader combinators ;
IN: io.windows.privileges

HOOK: set-privilege io-backend ( name ? -- ) inline

: with-privileges ( seq quot -- )
    over [ [ t set-privilege ] each ] curry compose
    swap [ [ f set-privilege ] each ] curry [ ] cleanup ; inline

{
    { [ os winnt? ] [ "io.windows.nt.privileges" require ] }
    { [ os wince? ] [ "io.windows.ce.privileges" require ] }
} cond
