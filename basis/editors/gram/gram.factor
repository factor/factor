USING: combinators.short-circuit editors io.files io.pathnames
io.standard-paths kernel make math.order math.parser namespaces
sequences system ;
IN: editors.gram

SINGLETON: gram

HOOK: find-gram-path os ( -- path/f )

M: object find-gram-path f ;

M: macos find-gram-path
    "app.liten.Gram" find-native-bundle
    [ "/Applications/Gram.app" ] unless*
    "Contents/MacOS/cli" append-path ;

M: linux find-gram-path
    {
        [ "gram" find-in-path ]
        [ "~/.local/bin/gram" absolute-path dup file-exists? [ drop f ] unless ]
    } 0|| ;

M: windows find-gram-path
    {
        [ "gram.exe" find-in-path ]
        [ { "Gram" } "gram.exe" find-in-applications ]
    } 0|| ;

: gram-path ( -- path )
    {
        [ \ gram-path get ]
        [ find-gram-path ]
        [ "gram" ]
    } 0|| ;

M: gram editor-command
    [ gram-path , 1 max number>string ":" glue , ] { } make ;
