! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: http.server.auth.providers kernel ;
IN: http.server.auth.providers.null

! Named "no" because we can say  no >>users

TUPLE: no ;

: no T{ no } ;

M: no get-user 2drop f ;

M: no new-user 2drop f ;

M: no update-user 2drop ;
