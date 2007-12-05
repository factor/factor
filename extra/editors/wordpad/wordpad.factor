USING: editors hardware-info.windows io.launcher kernel
math.parser namespaces sequences windows.shell32 ;
IN: editors.wordpad

: wordpad ( file line -- )
    [
        \ wordpad get-global % drop " " % "\"" % % "\"" %
    ] "" make run-detached ;

program-files "\\Windows NT\\Accessories\\wordpad.exe" append
\ wordpad set-global

[ wordpad ] edit-hook set-global
