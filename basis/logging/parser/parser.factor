! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar calendar.format calendar.parser
combinators io io.encodings.utf8 io.files kernel logging
logging.server make namespaces peg peg.parsers prettyprint
sequences splitting strings vectors words ;
IN: logging.parser

TUPLE: log-entry date level word-name message ;

: string-of ( quot -- parser )
    satisfy repeat0 [ >string ] action ; inline

SYMBOL: multiline

: date-parser ( -- parser )
    [ "]" member? not ] string-of [
        dup multiline-header =
        [ drop multiline ] [ rfc3339>timestamp ] if
    ] action
    "[" "]" surrounded-by ;

: log-level-parser ( -- parser )
    log-levels keys [
        [ name>> token ] keep [ nip ] curry action
    ] map choice ;

: word-name-parser ( -- parser )
    [ " :" member? not ] string-of ;

SYMBOL: malformed

: malformed-line-parser ( -- parser )
    [ drop t ] string-of
    [ log-entry new swap >>message malformed >>level ] action ;

: log-message-parser ( -- parser )
    [ drop t ] string-of
    [ 1vector ] action ;

: log-line-parser ( -- parser )
    [
        date-parser ,
        " " token hide ,
        log-level-parser ,
        " " token hide ,
        word-name-parser ,
        ": " token hide ,
        log-message-parser ,
    ] seq* [ first4 log-entry boa ] action
    malformed-line-parser 2choice ;

PEG: parse-log-line ( string -- entry ) log-line-parser ;

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
    log-path 1 log# dup file-exists?
    [ utf8 file-lines parse-log ] [ drop f ] if ;

GENERIC: log-timestamp. ( date -- )

M: timestamp log-timestamp. write-timestamp ;
M: word log-timestamp. drop "multiline" write ;

: log-entry. ( entry -- )
    "====== " write
    {
        [ date>> log-timestamp. bl ]
        [ level>> pprint bl ]
        [ word-name>> write nl ]
        [ message>> join-lines print ]
    } cleave ;

: log-entries. ( errors -- )
    [ log-entry. ] each ;
