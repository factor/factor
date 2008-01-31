! Basic SciTE integration for Factor.
!
! By Clemens F. Hofreither, 2007.
! clemens.hofreither@gmx.net
!
! In your .factor-rc or .factor-boot-rc,
! require this module and set the scite-path
! variable to point to your executable,
! if not on the path.
!
USING: io.files io.launcher kernel namespaces math
math.parser editors sequences windows.shell32 ;
IN: editors.scite

: scite-path ( -- path )
    \ scite-path get-global [
        program-files "wscite\\SciTE.exe" path+
    ] unless* ;

: scite-command ( file line -- cmd )
  swap
  [
    scite-path ,
    ,
    "-goto:" swap number>string append ,
  ] { } make ;

: scite-location ( file line -- )
  scite-command run-detached drop ;

[ scite-location ] edit-hook set-global
