! Copyright (C) 2008 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: arrays ascii combinators.short-circuit kernel make
math.parser peg peg.parsers sequences sequences.deep strings ;
IN: http.parsers

: except ( quot -- parser )
    [ not ] compose satisfy ; inline

: except-these ( quots -- parser )
    [ 1|| ] curry except ; inline

: cookie-key-disallow? ( ch -- ? )
    " \t,;=" member? ;

: tspecial? ( ch -- ? )
    "()<>@,;:\\\"/[]?={} \t" member? ;

: cookie-key-parser ( -- parser )
    { [ control? ] [ cookie-key-disallow? ] } except-these repeat1 ;

: token-parser ( -- parser )
    { [ control? ] [ tspecial? ] } except-these repeat1 ;

: case-insensitive ( parser -- parser' )
    [ flatten >string >lower ] action ;

: case-sensitive ( parser -- parser' )
    [ flatten >string ] action ;

: space-parser ( -- parser )
    [ " \t" member? ] satisfy repeat0 hide ;

: one-of ( strings -- parser )
    [ token ] map choice ;

: http-method-parser ( -- parser )
    { "OPTIONS" "GET" "HEAD" "POST" "PUT" "DELETE" "TRACE" "CONNECT" "PATCH" } one-of ;

: url-parser ( -- parser )
    [ " \t\r\n" member? ] except repeat1 case-sensitive ;

: http-version-parser ( -- parser )
    [
        "HTTP" token hide ,
        space-parser ,
        "/" token hide ,
        space-parser ,
        "1" token ,
        "." token ,
        { "0" "1" } one-of ,
    ] seq* [ "" concat-as ] action ;

: full-request-parser ( -- parser )
    [
        space-parser ,
        http-method-parser ,
        space-parser ,
        url-parser ,
        space-parser ,
        http-version-parser ,
        space-parser ,
    ] seq* ;

: simple-request-parser ( -- parser )
    [
        space-parser ,
        "GET" token ,
        space-parser ,
        url-parser ,
        space-parser ,
    ] seq* [ "1.0" suffix! ] action ;

PARTIAL-PEG: parse-request-line ( string -- triple )
    ! Triple is { method url version }
    full-request-parser simple-request-parser 2array choice ;

: text-parser ( -- parser )
    [ control? ] except ;

: response-code-parser ( -- parser )
    [ digit? ] satisfy 3 exactly-n [ string>number ] action ;

: response-message-parser ( -- parser )
    text-parser repeat0 case-sensitive ;

PARTIAL-PEG: parse-response-line ( string -- triple )
    ! Triple is { version code message }
    [
        space-parser ,
        http-version-parser ,
        space-parser ,
        response-code-parser ,
        space-parser ,
        response-message-parser ,
    ] seq* just ;

: crlf-parser ( -- parser )
    "\r\n" token ;

: lws-parser ( -- parser )
    [ " \t" member? ] satisfy repeat1 ;

: qdtext-parser ( -- parser )
    { [ CHAR: \" = ] [ control? ] } except-these ;

: quoted-char-parser ( -- parser )
    "\\" token hide any-char 2seq ;

: quoted-string-parser ( -- parser )
    quoted-char-parser qdtext-parser 2choice repeat0 "\"" "\"" surrounded-by ;

: ctext-parser ( -- parser )
    { [ control? ] [ "()" member? ] } except-these ;

: comment-parser ( -- parser )
    ctext-parser comment-parser 2choice repeat0 "(" ")" surrounded-by ;

: field-name-parser ( -- parser )
    token-parser case-insensitive ;

: field-content-parser ( -- parser )
    quoted-string-parser case-sensitive
    text-parser repeat0 case-sensitive
    2choice ;

PARTIAL-PEG: parse-header-line ( string -- pair )
    ! Pair is either { name value } or { f value }. If f, its a
    ! continuation of the previous header line.
    [
        field-name-parser ,
        space-parser ,
        ":" token hide ,
        space-parser ,
        field-content-parser ,
    ] seq*
    [
        lws-parser [ drop f ] action ,
        field-content-parser ,
    ] seq*
    2choice ;

: word-parser ( -- parser )
    token-parser quoted-string-parser 2choice ;

: value-parser ( -- parser )
    quoted-string-parser
    [ ";" member? ] except repeat0
    2choice case-sensitive ;

: attr-parser ( -- parser )
    cookie-key-parser case-sensitive ;

: av-pair-parser ( -- parser )
    [
        space-parser ,
        attr-parser ,
        space-parser ,
        [ "=" token , space-parser , value-parser , ] seq* [ last ] action optional ,
        space-parser ,
    ] seq* ;

: av-pairs-parser ( -- parser )
    av-pair-parser ";" token list-of optional ;

PARTIAL-PEG: (parse-set-cookie) ( string -- alist )
    av-pairs-parser just [ sift ] action ;

: cookie-value-parser ( -- parser )
    [
        space-parser ,
        attr-parser ,
        space-parser ,
        "=" token hide ,
        space-parser ,
        value-parser ,
        space-parser ,
    ] seq*
    [ ";,=" member? not ] satisfy repeat0 [ drop f ] action
    2choice ;

PARTIAL-PEG: (parse-cookie) ( string -- alist )
    cookie-value-parser [ ";," member? ] satisfy list-of
    optional just [ sift ] action ;
