! Copyright (C) 2014 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: alien.destructors command-line curl.ffi destructors
http.download io.backend io.streams.c kernel namespaces present
sequences ;

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
    CURLOPT_FILE swap normalize-path "wb" fopen &fclose curl-set-opt ;

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

: curl-download ( url -- path )
    dup download-name [ curl-download-as ] keep ;

: curl-main ( -- )
    command-line get [
        curl-init
        [ swap curl-set-url ]
        [ curl-perform ] bi
    ] each ;

MAIN: curl-main
