! Copyright (C) 2008, 2009 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors arrays assocs boxes continuations debugger io
io.encodings.utf8 io.files io.streams.string kernel namespaces
prettyprint quotations sequences strings xml.data xml.syntax
xml.writer ;
! USING: accessors kernel fry io io.encodings.utf8 io.files
! debugger prettyprint continuations namespaces boxes sequences
! arrays strings html io.streams.string assocs
! quotations xml.data xml.writer xml.syntax ;
IN: html.templates

MIXIN: template

GENERIC: call-template* ( template -- )

M: string call-template* write ;

M: callable call-template* call( -- ) ;

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

ERROR: no-boilerplate ;

M: no-boilerplate error.
    drop
    "get-title and set-title can only be used from within" print
    "a with-boilerplate form" print ;

SYMBOL: title

: set-title ( string -- )
    title get [ >box ] [ no-boilerplate ] if* ;

: get-title ( -- string )
    title get [ value>> ] [ no-boilerplate ] if* ;

: write-title ( -- )
    get-title write ;

SYMBOL: style

: add-style ( string -- )
    "\n" style get push-all
         style get push-all ;

: get-style ( -- string )
    style get >string ;

: write-style ( -- )
    get-style write ;

SYMBOL: script

: add-script ( string -- )
    "\n" script get push-all
         script get push-all ;

: get-script ( -- string )
    script get >string ;

: write-script ( -- )
    get-script write ;

SYMBOL: meta

: add-meta ( name content -- )
    2array meta get push ;

: get-meta ( -- xml )
    meta get [
        [XML <meta name=<-> content=<->/> XML]
    ] { } assoc>map ;

: write-meta ( -- )
    get-meta write-xml ;

SYMBOL: atom-feeds

: add-atom-feed ( title url -- )
    2array atom-feeds get push ;

: get-atom-feeds ( -- xml )
    atom-feeds get [
        [XML
            <link
                rel="alternate"
                type="application/atom+xml"
                title=<->
                href=<->/>
        XML]
    ] { } assoc>map ;

: write-atom-feeds ( -- )
    get-atom-feeds write-xml ;

SYMBOL: nested-template?

SYMBOL: next-template

: call-next-template ( -- )
    next-template get write ;

M: f call-template* drop call-next-template ;

: with-boilerplate ( child master -- )
    [
        title [ [ <box> ] unless* ] change
        style [ [ SBUF" " clone ] unless* ] change
        script [ [ SBUF" " clone ] unless* ] change
        meta [ [ V{ } clone ] unless* ] change
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
