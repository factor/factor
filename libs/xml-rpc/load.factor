! Copyright (C) 2005, 2006 Daniel Ehrenberg
! See http://factorcode.org/license.txt for BSD license.
REQUIRES: libs/xml libs/base64 libs/http-client apps/http-server ;

PROVIDE: libs/xml-rpc
{ +files+ {
    "xml-rpc.factor"
    "xml-rpc.facts"
} }
{ +tests+ {
    "test.factor"
} } ;
