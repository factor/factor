! Copyright (C) 2014 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: alien alien.c-types alien.data alien.destructors
alien.syntax command-line curl.ffi destructors io
io.encodings.string io.encodings.utf8 io.streams.c kernel math
namespaces present sequences ;

IN: curl

<PRIVATE

DESTRUCTOR: curl_easy_cleanup

DESTRUCTOR: fclose

: check-code ( code -- )
    CURLE_OK assert= ;

: curl-init ( -- CURL )
    curl_easy_init &curl_easy_cleanup ;

: curl-set-opt ( CURL key value -- )
    curl_easy_setopt check-code ;

: curl-set-url ( CURL url -- )
    CURLOPT_URL swap present curl-set-opt ;

: curl-set-file ( CURL path -- )
    CURLOPT_FILE swap "wb" fopen &fclose curl-set-opt ;

: curl-perform ( CURL -- )
    curl_easy_perform check-code ;

PRIVATE>

: curl-download-as ( url path -- )
    [
        curl-init
        [ swap curl-set-file ]
        [ swap curl-set-url ]
        [ curl-perform ] tri
    ] with-destructors ;

: curl-main ( -- )
    command-line get [
        curl-init
        [ swap curl-set-url ]
        [ curl-perform ] bi
    ] each ;

MAIN: curl-main
