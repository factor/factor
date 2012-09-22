! Copyright (C) 2009-2012 John Benediktsson
! See http://factorcode.org/license.txt for BSD license

USING: arrays assocs combinators environment io kernel
math.parser regexp sequences splitting strings unicode.case
urls.encoding ;

IN: cgi

<PRIVATE

: (query-string) ( string -- assoc )
    query>assoc [ nip ] assoc-filter [
        [ [ CHAR: \s = ] trim ]
        [ dup string? [ 1array ] when ] bi*
    ] assoc-map ;

: parse-get ( -- assoc )
    "QUERY_STRING" os-env "" or (query-string) ;

: (content-type) ( string -- params media/type )
    ";" split unclip [
        [ H{ } clone ] [ first (query-string) ] if-empty
    ] dip ;

: (multipart) ( -- assoc )
    "multipart unsupported" throw ;

: (urlencoded) ( -- assoc )
    "CONTENT_LENGTH" os-env "0" or string>number
    read [ "" ] [ "&" append ] if-empty
    "QUERY_STRING" os-env [ append ] when* (query-string) ;

: parse-post ( -- assoc )
    "CONTENT_TYPE" os-env "" or (content-type) {
       { "multipart/form-data"               [ (multipart) ] }
       { "application/x-www-form-urlencoded" [ (urlencoded) ] }
       [ drop parse-get ]
   } case nip ;

PRIVATE>

: <cgi-form> ( -- assoc )
    "REQUEST_METHOD" os-env "GET" or >upper {
        { "GET"  [ parse-get ] }
        { "POST" [ parse-post ] }
        [ "Unknown request method" throw ]
    } case ;

: <cgi-simple-form> ( -- assoc )
    <cgi-form> [ first ] assoc-map ;


