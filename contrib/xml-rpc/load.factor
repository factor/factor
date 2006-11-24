! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
REQUIRES: contrib/xml contrib/base64 contrib/http-client
    contrib/httpd ;

PROVIDE: contrib/xml-rpc
{ +files+ {
    "xml-rpc.factor"
    "xml-rpc.facts"
} }
{ +tests+ {
    "test.factor"
} } ;
