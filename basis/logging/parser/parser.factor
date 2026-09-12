! Copyright (C) 2008, 2010 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs calendar calendar.format calendar.parser
combinators io io.encodings.binary io.encodings.string
io.encodings.utf8 io.files kernel logging
logging.server make math math.order namespaces peg peg.parsers prettyprint
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
    date>> multiline eq? ;

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

ERROR: invalid-log-tail-limit limit ;

! Bound the raw read, including a single oversized or unterminated line.
! Discard a partial first line before decoding, since it may split UTF-8.
:: log-file-tail ( path limit -- lines omitted-bytes )
    limit integer? [ limit 0 > ] [ f ] if
    [ limit invalid-log-tail-limit ] unless
    path binary [
        input-stream get stream-length 0 or limit - 0 max :> start
        start 0 > [
            start 1 - seek-absolute seek-input
            read1 CHAR: \n =
        ] [ t ] if :> line-boundary?
        limit read B{ } or :> bytes
        line-boundary? [ 0 ] [
            CHAR: \n bytes index [ 1 + ] [ bytes length ] if*
        ] if :> partial
        bytes partial tail utf8 decode split-lines
        start partial +
    ] with-file-reader ;

GENERIC: log-timestamp. ( date -- )

M: timestamp log-timestamp. write-timestamp ;
M: word log-timestamp. drop "multiline" write ;

: log-entry. ( entry -- )
    "====== " write
    {
        [ date>> log-timestamp. bl ]
        [ level>> pprint bl ]
        [ word-name>> print ]
        [ message>> join-lines print ]
    } cleave ;

: log-entries. ( errors -- )
    [ log-entry. ] each ;
