! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: http.server.sessions accessors ;
IN: http.server.auth

SYMBOL: logged-in-user

: uid ( -- string ) logged-in-user sget username>> ;
