! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: alien.syntax alien.parser words x11.io sequences kernel ;
IN: x11.syntax

SYNTAX: X-FUNCTION:
    (FUNCTION:)
    [ \ awaken-event-loop suffix ] dip
    define-declared ;