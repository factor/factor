! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: alien.parser kernel sequences words x11.io ;
IN: x11.syntax

SYNTAX: X-FUNCTION:
    (FUNCTION:) make-function
    [ \ awaken-event-loop suffix ] dip
    define-declared ;
