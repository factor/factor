! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel generic generic.parser words fry ;
IN: method-chains

: AFTER: (M:) dupd '[ [ _ (call-next-method) ] _ bi ] define ; parsing
: BEFORE: (M:) over '[ _ [ _ (call-next-method) ] bi ] define ; parsing
