USING: editors io.launcher kernel math.parser namespaces ;
IN: editors.ultraedit

: ultraedit ( file line -- )
    [
        \ ultraedit get-global % " " % swap % "/" % # "/1" %
    ] "" make run-detached ;

! Put the path in your .factor-boot-rc
! "K:\\Program Files (x86)\\IDM Computer Solutions\\UltraEdit-32\\uedit32.exe" \ ultraedit set-global

[ ultraedit ] edit-hook set-global
