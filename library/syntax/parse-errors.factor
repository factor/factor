! Copyright (C) 2005 Slava Pestov.
! See http://factor.sf.net/license.txt for BSD license.
IN: parser
USING: errors generic kernel namespaces io ;

TUPLE: parse-error file line col text ;

: parse-error ( msg -- )
    file get line-number get "col" get "line" get
    <parse-error> [ set-delegate ] keep throw ;

: with-parser ( quot -- ) [ [ parse-error ] when* ] catch ;
