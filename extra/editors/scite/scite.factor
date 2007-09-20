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
USING: io.launcher kernel namespaces math math.parser
editors ;
IN: editors.scite

SYMBOL: scite-path

"scite" scite-path set-global

: scite-command ( file line -- cmd )
  swap
  [ scite-path get %
    " \"" %
    %
    "\" -goto:" %
    #
  ] "" make ;

: scite-location ( file line -- )
  scite-command run-detached ;

[ scite-location ] edit-hook set-global
