! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: kernel ;
IN: http.server.auth.providers

GENERIC: check-login ( password user provider -- ? )

GENERIC: new-user ( user provider -- )

GENERIC: set-password ( password user provider -- )

TUPLE: user-exists name ;

: user-exists ( name -- * ) \ user-exists construct-boa throw ;

TUPLE: no-such-user name ;

: no-such-user ( name -- * ) \ no-such-user construct-boa throw ;
