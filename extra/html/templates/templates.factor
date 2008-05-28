! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel fry io io.encodings.utf8 io.files
debugger prettyprint continuations namespaces boxes sequences
arrays strings html.elements io.streams.string quotations ;
IN: html.templates

MIXIN: template

GENERIC: call-template* ( template -- )

M: string call-template* write ;

M: callable call-template* call ;

M: object call-template* output-stream get stream-copy ;

ERROR: template-error template error ;

M: template-error error.
    "Error while processing template " write
    [ template>> short. ":" print nl ]
    [ error>> error. ]
    bi ;

: call-template ( template -- )
    [ call-template* ] [ \ template-error boa rethrow ] recover ;

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
    next-template get write-html ;

M: f call-template* drop call-next-template ;

: with-boilerplate ( body template -- )
    [
        title get [ <box> title set ] unless
        atom-feed get [ <box> atom-feed set ] unless
        style get [ SBUF" " clone style set ] unless

        [
            [
                nested-template? on
                call-template
            ] with-string-writer
            next-template set
        ]
        [ call-template ]
        bi*
    ] with-scope ; inline

: template-convert ( template output -- )
    utf8 [ call-template ] with-file-writer ;
