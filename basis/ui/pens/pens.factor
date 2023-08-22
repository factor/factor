! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel ;
IN: ui.pens

GENERIC: draw-interior ( gadget pen -- )

GENERIC: draw-boundary ( gadget pen -- )

GENERIC: pen-background ( gadget pen -- color )

M: object pen-background 2drop f ;

GENERIC: pen-foreground ( gadget pen -- color )

M: object pen-foreground 2drop f ;

GENERIC: pen-pref-dim ( gadget pen -- dim )

M: object pen-pref-dim 2drop { 0 0 } ;
