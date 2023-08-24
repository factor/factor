USING: combinators.short-circuit editors io.standard-paths
kernel make namespaces ;
IN: editors.editpadlite

SINGLETON: editpadlite

: editpadlite-path ( -- path )
    \ editpadlite-path get [
        {
            [ { "Just Great Software" "JGsoft" } "editpadlite.exe" find-in-applications ]
            [ { "Just Great Software" "JGsoft" } "editpadlite7.exe" find-in-applications ]
            [ "editpadlite7.exe" ]
        } 0||
    ] unless* ;

M: editpadlite editor-command
    drop
    [ editpadlite-path , , ] { } make ;
