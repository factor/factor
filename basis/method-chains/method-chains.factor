! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: kernel generic generic.parser words ;
IN: method-chains

SYNTAX: AFTER: (M:) dupd '[ [ _ (call-next-method) ] _ bi ] define ;
SYNTAX: BEFORE: (M:) over '[ _ [ _ (call-next-method) ] bi ] define ;
