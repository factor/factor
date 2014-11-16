! Copyright (C) 2009, 2010 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: debugger fry kernel namespaces twitter ;
IN: mason.twitter

: mason-tweet ( message -- )
    twitter-access-token get [ '[ _ tweet ] try ] [ drop ] if ;
