USING: editors io.launcher math.parser namespaces ;
IN: editors.editplus

: editplus ( file line -- )
    [
        \ editplus get-global % " -cursor " % # " " % %
    ] "" make run-detached ;

! Put in your .factor-boot-rc
! "c:\\Program Files\\EditPlus\\editplus.exe" \ editplus set-global

[ editplus ] edit-hook set-global
