! Copyright (C) 2010 Slava Pestov.
USING: accessors continuations debugger euler.b-rep gml.parser
gml.printer gml.runtime io io.encodings.utf8 io.files kernel
namespaces sequences ;
IN: gml

TUPLE: gml-file-error pathname error ;

C: <gml-file-error> gml-file-error

M: gml-file-error error.
    "Error in GML file \"" write
    dup pathname>> write "\":" print nl
    error>> error. ;

: gml-stack. ( gml -- )
    operand-stack>> [
        "Operand stack:" print
        [ "• " write print-gml ] each
    ] unless-empty ;

SYMBOL: gml

: make-gml ( quot -- gml b-rep )
    [
        <gml> gml set
        <b-rep> b-rep set
        call
        gml get
        b-rep get dup finish-b-rep
    ] with-scope ; inline

: with-gml ( gml b-rep quot -- )
    [
        [ gml set ]
        [ b-rep set ]
        [ call ]
        tri*
    ] with-scope ; inline

: run-gml-string ( string -- )
    [ gml get ] dip parse-gml exec drop ;

: run-gml-file ( pathname -- )
    [ utf8 file-contents run-gml-string ]
    [ <gml-file-error> rethrow ]
    recover ;

SYMBOLS: pre-hook post-hook ;

[ ] pre-hook set-global
[ ] post-hook set-global

: (gml-listener) ( -- )
    "GML> " write flush readln [
        '[
            pre-hook get call( -- )
            _ run-gml-string
            post-hook get call( -- )
        ] try
        [ gml get gml-stack. ] try
        (gml-listener)
    ] when* ;

: gml-listener ( -- )
    [ (gml-listener) ] make-gml 2drop ;

MAIN: gml-listener
