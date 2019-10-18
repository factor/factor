! Copyright (C) 2006, 2007 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: definitions
USING: kernel sequences namespaces errors ;

GENERIC: see ( defspec -- )

GENERIC: where ( defspec -- loc )

GENERIC: forget ( defspec -- )

M: f forget drop ;

GENERIC: synopsis* ( defspec -- )

GENERIC: definer ( word -- start end )

GENERIC: definition ( spec -- quot/f )
