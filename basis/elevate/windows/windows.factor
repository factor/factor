USING: io.launcher elevate ;
IN: elevate.windows


<PRIVATE
! TODO
M: windows elevated
    3drop run-process ;

! no-op (not possible to lower)
M: windows lowered ;
PRIVATE>