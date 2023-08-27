! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
IN: prettyprint.custom

GENERIC: pprint* ( obj -- )
GENERIC: pprint-object ( obj -- )
GENERIC: pprint-delims ( obj -- start end )
GENERIC: >pprint-sequence ( obj -- seq )
GENERIC: pprint-narrow? ( obj -- ? )
