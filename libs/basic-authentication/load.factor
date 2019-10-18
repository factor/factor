! Copyright (c) 2007 Chris Double.
! See http://factor.sf.net/license.txt for BSD license.
USING: io ;

REQUIRES: libs/base64 libs/crypto apps/http-server ;

PROVIDE: libs/basic-authentication
{ +files+ {
    "basic-authentication.factor"
    "basic-authentication.facts"
} }
{ +tests+ {
    "tests.factor"
} } 
{ +help+ {
  "http-authentication" "basic-authentication" }
} ;

USE: httpd
MAIN: apps/http-server 8888 httpd ;
