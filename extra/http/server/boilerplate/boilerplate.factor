! Copyright (c) 2008 Slava Pestov
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel namespaces boxes sequences strings
io io.streams.string arrays
html.elements
http
http.server
http.server.sessions
http.server.templating ;
IN: http.server.boilerplate

TUPLE: boilerplate < filter-responder template ;

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

SYMBOL: atom-feed

: set-atom-feed ( title url -- )
    2array atom-feed get >box ;

: write-atom-feed ( -- )
    atom-feed get value>> [
        <link "alternate" =rel "application/atom+xml" =type
        [ first =title ] [ second =href ] bi
        link/>
    ] when* ;

SYMBOL: nested-template?

SYMBOL: next-template

: call-next-template ( -- )
    next-template get write ;

M: f call-template* drop call-next-template ;

: with-boilerplate ( body template -- )
    [
        title get [ <box> title set ] unless
        atom-feed get [ <box> atom-feed set ] unless
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

M: boilerplate call-responder*
    tuck call-next-method
    dup "content-type" header "text/html" = [
        clone swap template>>
        [ [ with-boilerplate ] 2curry ] curry change-body
    ] [ nip ] if ;
