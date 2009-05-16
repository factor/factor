! Copyright (C) 2008 Slava Pestov.
! See http://factorcode.org/license.txt for BSD license.
USING: combinators.short-circuit math math.order math.parser
kernel sequences sequences.deep peg peg.parsers assocs arrays
hashtables strings namespaces make ascii ;
IN: http.parsers

: except ( quot -- parser )
    [ not ] compose satisfy ; inline

: except-these ( quots -- parser )
    [ 1|| ] curry except ; inline

: ctl? ( ch -- ? )
    { [ 0 31 between? ] [ 127 = ] } 1|| ;

: tspecial? ( ch -- ? )
    "()<>@,;:\\\"/[]?={} \t" member? ;

: 'token' ( -- parser )
    { [ ctl? ] [ tspecial? ] } except-these repeat1 ;

: case-insensitive ( parser -- parser' )
    [ flatten >string >lower ] action ;

: case-sensitive ( parser -- parser' )
    [ flatten >string ] action ;

: 'space' ( -- parser )
    [ " \t" member? ] satisfy repeat0 hide ;

: one-of ( strings -- parser )
    [ token ] map choice ;

: 'http-method' ( -- parser )
    { "OPTIONS" "GET" "HEAD" "POST" "PUT" "DELETE" "TRACE" "CONNECT" } one-of ;

: 'url' ( -- parser )
    [ " \t\r\n" member? ] except repeat1 case-sensitive ;

: 'http-version' ( -- parser )
    [
        "HTTP" token hide ,
        'space' ,
        "/" token hide ,
        'space' ,
        "1" token ,
        "." token ,
        { "0" "1" } one-of ,
    ] seq* [ concat >string ] action ;

PEG: parse-request-line ( string -- triple )
    #! Triple is { method url version }
    [ 
        'space' ,
        'http-method' ,
        'space' ,
        'url' ,
        'space' ,
        'http-version' ,
        'space' ,
    ] seq* just ;

: 'text' ( -- parser )
    [ ctl? ] except ;

: 'response-code' ( -- parser )
    [ digit? ] satisfy 3 exactly-n [ string>number ] action ;

: 'response-message' ( -- parser )
    'text' repeat0 case-sensitive ;

PEG: parse-response-line ( string -- triple )
    #! Triple is { version code message }
    [
        'space' ,
        'http-version' ,
        'space' ,
        'response-code' ,
        'space' ,
        'response-message' ,
    ] seq* just ;

: 'crlf' ( -- parser )
    "\r\n" token ;

: 'lws' ( -- parser )
    [ " \t" member? ] satisfy repeat1 ;

: 'qdtext' ( -- parser )
    { [ CHAR: " = ] [ ctl? ] } except-these ;

: 'quoted-char' ( -- parser )
    "\\" token hide any-char 2seq ;

: 'quoted-string' ( -- parser )
    'quoted-char' 'qdtext' 2choice repeat0 "\"" "\"" surrounded-by ;

: 'ctext' ( -- parser )
    { [ ctl? ] [ "()" member? ] } except-these ;

: 'comment' ( -- parser )
    'ctext' 'comment' 2choice repeat0 "(" ")" surrounded-by ;

: 'field-name' ( -- parser )
    'token' case-insensitive ;

: 'field-content' ( -- parser )
    'quoted-string' case-sensitive
    'text' repeat0 case-sensitive
    2choice ;

PEG: parse-header-line ( string -- pair )
    #! Pair is either { name value } or { f value }. If f, its a
    #! continuation of the previous header line.
    [
        'field-name' ,
        'space' ,
        ":" token hide ,
        'space' ,
        'field-content' ,
    ] seq*
    [
        'lws' [ drop f ] action ,
        'field-content' ,
    ] seq*
    2choice ;

: 'word' ( -- parser )
    'token' 'quoted-string' 2choice ;

: 'value' ( -- parser )
    'quoted-string'
    [ ";" member? ] except repeat0
    2choice case-sensitive ;

: 'attr' ( -- parser )
    'token' case-insensitive ;

: 'av-pair' ( -- parser )
    [
        'space' ,
        'attr' ,
        'space' ,
        [ "=" token , 'space' , 'value' , ] seq* [ peek ] action optional ,
        'space' ,
    ] seq* ;

: 'av-pairs' ( -- parser )
    'av-pair' ";" token list-of optional ;

PEG: (parse-set-cookie) ( string -- alist )
    'av-pairs' just [ sift ] action ;

: 'cookie-value' ( -- parser )
    [
        'space' ,
        'attr' ,
        'space' ,
        "=" token hide ,
        'space' ,
        'value' ,
        'space' ,
    ] seq*
    [ ";,=" member? not ] satisfy repeat0 [ drop f ] action
    2choice ;

PEG: (parse-cookie) ( string -- alist )
    'cookie-value' [ ";," member? ] satisfy list-of
    optional just [ sift ] action ;
