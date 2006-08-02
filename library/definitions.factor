! Copyright (C) 2006 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: definitions
USING: sequences ;

GENERIC: see ( defspec -- )

GENERIC: where ( defspec -- loc )

GENERIC: subdefs ( defspec -- seq )

: see-subdefs ( word -- ) subdefs [ see ] each ;

GENERIC: forget ( defspec -- )

GENERIC: synopsis ( defspec -- str )
