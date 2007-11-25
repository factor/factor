USING: editors io.launcher math.parser namespaces ;
IN: editors.notepadpp

: notepadpp ( file line -- )
    [
        \ notepadpp get-global % " -n" % # " " % %
    ] "" make run-detached ;

! Put in your .factor-boot-rc
! "c:\\Program Files\\notepad++\\notepad++.exe" \ notepadpp set-global
! "k:\\Program Files (x86)\\notepad++\\notepad++.exe" \ notepadpp set-global

[ notepadpp ] edit-hook set-global
