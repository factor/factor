! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors peg peg.parsers memoize kernel sequences
logging arrays words strings vectors io io.files
io.encodings.utf8 namespaces make combinators logging.server
calendar calendar.format assocs ;
IN: logging.parser

TUPLE: log-entry date level word-name message ;

: string-of ( quot -- parser )
    satisfy repeat0 [ >string ] action ; inline

SYMBOL: multiline

: 'date' ( -- parser )
    [ "]" member? not ] string-of [
        dup multiline-header =
        [ drop multiline ] [ rfc3339>timestamp ] if
    ] action
    "[" "]" surrounded-by ;

: 'log-level' ( -- parser )
    log-levels keys [
        [ name>> token ] keep [ nip ] curry action
    ] map choice ;

: 'word-name' ( -- parser )
    [ " :" member? not ] string-of ;

SYMBOL: malformed

: 'malformed-line' ( -- parser )
    [ drop t ] string-of
    [ log-entry new swap >>message malformed >>level ] action ;

: 'log-message' ( -- parser )
    [ drop t ] string-of
    [ 1vector ] action ;

: 'log-line' ( -- parser )
    [
        'date' ,
        " " token hide ,
        'log-level' ,
        " " token hide ,
        'word-name' ,
        ": " token hide ,
        'log-message' ,
    ] seq* [ first4 log-entry boa ] action
    'malformed-line' 2choice ;

PEG: parse-log-line ( string -- entry ) 'log-line' ;

: malformed? ( line -- ? )
    level>> malformed eq? ;

: multiline? ( line -- ? )
    level>> multiline eq? ;

: malformed-line ( line -- )
    "Warning: malformed log line:" print
    message>> print ;

: add-multiline ( line -- )
    building get empty? [
        "Warning: log begins with multiline entry" print drop
    ] [
        message>> first building get last message>> push
    ] if ;

: parse-log ( lines -- entries )
    [
        [
            parse-log-line {
                { [ dup malformed? ] [ malformed-line ] }
                { [ dup multiline? ] [ add-multiline ] }
                [ , ]
            } cond
        ] each
    ] { } make ;

: parse-log-file ( service -- entries )
    log-path 1 log# dup exists?
    [ utf8 file-lines parse-log ] [ drop f ] if ;
