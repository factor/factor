! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
IN: http.server.auth.providers.assoc
USING: new-slots accessors assocs kernel
http.server.auth.providers ;

TUPLE: assoc-auth-provider assoc ;

: <assoc-auth-provider> ( -- provider )
    H{ } clone assoc-auth-provider construct-boa ;

M: assoc-auth-provider check-login
    assoc>> at = ;

M: assoc-auth-provider new-user
    assoc>>
    2dup key? [ drop user-exists ] when
    t -rot set-at ;

M: assoc-auth-provider set-password
    assoc>>
    2dup key? [ drop no-such-user ] unless
    set-at ;
