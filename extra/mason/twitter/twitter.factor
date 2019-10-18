! Copyright (C) 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: debugger fry kernel mason.config namespaces twitter ;
IN: mason.twitter

: mason-tweet ( message -- )
    builder-twitter-username get builder-twitter-password get and
    [
        [
            builder-twitter-username get twitter-username set
            builder-twitter-password get twitter-password set
            '[ _ tweet ] try
        ] with-scope
    ] [ drop ] if ;