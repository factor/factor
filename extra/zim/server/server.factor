! Copyright (C) 2023 John Benediktsson
! See https://factorcode.org/license.txt for BSD license

USING: accessors combinators.short-circuit command-line
formatting http.server http.server.responses io
io.encodings.binary io.servers kernel math math.parser
namespaces sequences sequences.extras zim ;

IN: zim.server

TUPLE: zim-responder zim ;

: <zim-responder> ( path -- zim-responder )
    read-zim zim-responder boa ;

M: zim-responder call-responder*
    [
        dup { [ length 1 > ] [ first length 1 = ] } 1&&
        [ unclip-slice first ] [ f ] if swap "/" join
        dup { "" "index.htm" "index.html" "main.htm" "main.html" }
        member? [ drop f ] when
    ] [
        zim>> [
            over [ read-entry-url ] [ 2nip read-main-page ] if
        ] with-zim
    ] bi* 2dup and [
        <content> binary >>content-encoding
    ] [
        2drop <404>
    ] if ;

: zim-main ( -- )
    command-line get [
        "Usage: zim path [port]" print
    ] [
        ?first2 [ string>number ] [ 8080 ] if*
        2dup "Serving '%s' on port %d\n" printf flush
        swap <zim-responder> main-responder set-global
        httpd wait-for-server
    ] if-empty ;

MAIN: zim-main
