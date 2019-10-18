USING: combinators.short-circuit editors io.standard-paths
kernel make math.parser namespaces sequences ;
IN: editors.editpadpro

SINGLETON: editpadpro
editpadpro editor-class set-global

: editpadpro-path ( -- path )
    \ editpadpro-path get [
        {
            [ { "Just Great Software" "JGsoft" } "editpadpro.exe" find-in-applications ]
            [ { "Just Great Software" "JGsoft" } "editpadpro7.exe" find-in-applications ]
            [ "editpadpro7.exe" ]
        } 0||
    ] unless* ;

M: editpadpro editor-command ( file line -- command )
    [
        editpadpro-path , number>string "/l" prepend , ,
    ] { } make ;
