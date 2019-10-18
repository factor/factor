USING: editors io.files io.launcher kernel math.parser
namespaces sequences windows.shell32 ;
IN: editors.ted-notepad

: ted-notepad-path
    \ ted-notepad-path get-global [
        program-files "\\TED Notepad\\TedNPad.exe" path+
    ] unless* ;

: ted-notepad ( file line -- )
    [
        ted-notepad-path % " /l" % #
        " " % %
    ] "" make run-detached ;

[ ted-notepad ] edit-hook set-global
