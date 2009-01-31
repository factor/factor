! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors kernel fry io io.encodings.utf8 io.files
debugger prettyprint continuations namespaces boxes sequences
arrays strings html io.streams.string
quotations xml.data xml.writer xml.literals ;
IN: html.templates

MIXIN: template

GENERIC: call-template* ( template -- )

M: string call-template* write ;

M: callable call-template* call ;

M: xml call-template* write-xml ;

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

SYMBOL: atom-feeds

: add-atom-feed ( title url -- )
    2array atom-feeds get push ;

: write-atom-feeds ( -- )
    atom-feeds get [
        first2 [XML
            <link
                rel="alternate"
                type="application/atom+xml"
                title=<->
                href=<->/>
        XML] write-xml
    ] each ;

SYMBOL: nested-template?

SYMBOL: next-template

: call-next-template ( -- )
    next-template get write-html ;

M: f call-template* drop call-next-template ;

: with-boilerplate ( child master -- )
    [
        title [ <box> or ] change
        style [ SBUF" " clone or ] change
        atom-feeds [ V{ } like ] change

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
