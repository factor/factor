USING: editors io.launcher kernel math.parser namespaces ;
IN: editors.ted-notepad

: ted-notepad ( file line -- )
    [
        \ ted-notepad get-global % " /l" % #
        " " % %
    ] "" make run-detached ;

[ ted-notepad ] edit-hook set-global
