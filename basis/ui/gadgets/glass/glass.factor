! Copyright (C) 2005, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces ui.gadgets ui.gadgets.worlds
ui.gestures ;
IN: ui.gadgets.glass

TUPLE: glass < gadget ;

: <glass> ( child loc -- glass )
    >>loc glass new-gadget swap add-gadget ;

M: glass layout* gadget-child prefer ;

: hide-glass ( world -- )
    [ [ unparent ] when* f ] change-glass drop ;

: show-glass ( world child loc -- )
    <glass>
    [ [ hide-glass ] [ hand-clicked set-global ] bi* ]
    [ [ add-gadget ] [ >>glass ] bi drop ]
    2bi ;

\ glass H{
    { T{ button-down } [ find-world [ hide-glass ] when* ] }
    { T{ drag } [ update-clicked drop ] }
} set-gestures