! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel ;
IN: ui.pens

GENERIC: draw-interior ( gadget interior -- )

GENERIC: draw-boundary ( gadget boundary -- )

GENERIC: pen-pref-dim ( gadget pen -- dim )

M: object pen-pref-dim 2drop { 0 0 } ;