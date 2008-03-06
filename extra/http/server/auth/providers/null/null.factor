! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: http.server.auth.providers kernel ;
IN: http.server.auth.providers.null

TUPLE: null-auth-provider ;

: null-auth-provider T{ null-auth-provider } ;

M: null-auth-provider check-login 3drop f ;

M: null-auth-provider new-user 3drop f ;

M: null-auth-provider set-password 3drop f ;
