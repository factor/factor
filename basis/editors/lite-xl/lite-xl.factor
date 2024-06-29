USING: combinators.short-circuit editors io.pathnames
io.standard-paths kernel make namespaces strings system ;
IN: editors.lite-xl

SINGLETON: lite-xl

SYMBOL: lite-xl-editor-path

HOOK: find-lite-xl-editor-path os ( -- path )

M: unix find-lite-xl-editor-path "xl" ?find-in-path ;

M: macos find-lite-xl-editor-path { "open" "-a" "Lite XL" } ;

M: windows find-lite-xl-editor-path
    { "lite-xl" } "xl.exe" find-in-applications
    [ "xl.exe" ] unless* ;

M: lite-xl editor-command
    [
        lite-xl-editor-path get [ find-lite-xl-editor-path ] unless*
        dup { [ string? ] [ pathname? ] } 1|| [ , ] [ % ] if
        [ , ] [ drop ] bi*
    ] { } make ;
