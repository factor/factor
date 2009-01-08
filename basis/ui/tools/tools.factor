! Copyright (C) 2006, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: ui.tools.operations ui.tools.listener ui kernel ;
IN: ui.tools

: main ( -- )
    restore-windows? [ restore-windows ] [ listener-window ] if ;

MAIN: main