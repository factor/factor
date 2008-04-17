! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces boxes sequences strings
io io.streams.string
http
http.server
http.server.templating ;
IN: http.server.boilerplate

TUPLE: boilerplate responder template ;

: <boilerplate> f boilerplate boa ;

SYMBOL: title

: set-title ( string -- )
    title get >box ;

: write-title ( -- )
    title get value>> write ;

SYMBOL: style

: add-style ( string -- )
    "\n" style get push-all
         style get push-all ;

: write-style ( -- )
    style get >string write ;

SYMBOL: nested-template?

SYMBOL: next-template

: call-next-template ( -- )
    next-template get write ;

M: f call-template drop call-next-template ;

: with-boilerplate ( body template -- )
    [
        title get [ <box> title set ] unless
        style get [ SBUF" " clone style set ] unless

        [
            [
                nested-template? on
                write-response-body*
            ] with-string-writer
            next-template set
        ]
        [ call-template ]
        bi*
    ] with-scope ; inline

M: boilerplate call-responder
    [ responder>> call-responder clone ] [ template>> ] bi
    [ [ with-boilerplate ] 2curry ] curry change-body ;
