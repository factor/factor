! Copyright (c) 2007 Chris Double.
! See http://factor.sf.net/license.txt for BSD license.
USING: io ;

REQUIRES: libs/base64 libs/crypto libs/httpd ;

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
MAIN: libs/httpd 8888 httpd ;
