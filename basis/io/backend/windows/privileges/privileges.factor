USING: io.backend kernel continuations sequences
system vocabs.loader combinators ;
IN: io.backend.windows.privileges

HOOK: set-privilege io-backend ( name ? -- ) inline

: with-privileges ( seq quot -- )
    over [ [ t set-privilege ] each ] curry compose
    swap [ [ f set-privilege ] each ] curry [ ] cleanup ; inline

{
    { [ os winnt? ] [ "io.backend.windows.nt.privileges" require ] }
    { [ os wince? ] [ "io.backend.windows.ce.privileges" require ] }
} cond
