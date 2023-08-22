! Copyright (C) 2009 Chris Double. All Rights Reserved.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs base64 calendar calendar.format
calendar.parser checksums.hmac checksums.sha combinators http
http.client kernel make math.order namespaces sequences
sorting strings xml xml.traversal ;
IN: s3

SYMBOL: key-id
SYMBOL: secret-key

<PRIVATE

TUPLE: s3-request path mime-type date method headers bucket data ;

: hashtable>headers ( hashtable -- seq )
    [
        [ swap % ":" % % "\n" % ] "" make
    ] { } assoc>map sort ;

: signature ( s3-request -- string )
    [
        {
            [ method>> % "\n" % "\n" % ]
            [ mime-type>> % "\n" % ]
            [ date>> timestamp>rfc822 % "\n" % ]
            [ headers>> [ hashtable>headers [ % ] each ] when* ]
            [ bucket>> [ "/" % % ] when* ]
            [ path>> % ]
        } cleave
    ] "" make ;

: sign ( s3-request -- string )
    [
        "AWS " %
        key-id get %
        ":" %
        signature secret-key get sha1 hmac-bytes >base64 %
    ] "" make ;

: s3-url ( s3-request -- string )
    [
        "https://" %
        dup bucket>> [ % "." % ] when*
        "s3.amazonaws.com" %
        path>> %
    ] "" make ;

: <s3-request> ( bucket path headers method -- request )
    s3-request new
        swap >>method
        swap >>headers
        swap >>path
        swap >>bucket
        now >>date ;

: sign-http-request ( s3-request http-request -- request )
    over date>> timestamp>rfc822 "Date" set-header
    swap sign "Authorization" set-header ;

: s3-get ( bucket path headers -- request data )
    "GET" <s3-request> dup s3-url <get-request>
    sign-http-request http-request ;

: s3-put ( data bucket path headers -- request data )
    "PUT" <s3-request> dup s3-url swapd <put-request>
    sign-http-request http-request ;

PRIVATE>

TUPLE: bucket name date ;

<PRIVATE

: (buckets) ( xml -- seq )
    "Buckets" tag-named
    "Bucket" tags-named [
        [ "Name" tag-named children>string ]
        [ "CreationDate" tag-named children>string ] bi bucket boa
    ] map ;
PRIVATE>

: buckets ( -- seq )
    f "/" H{ } clone s3-get nip >string string>xml (buckets) ;

: sorted-buckets ( -- seq )
    buckets [ date>> rfc3339>timestamp ] sort-by ;

<PRIVATE
: bucket-url ( bucket -- string )
    [ "https://" % % ".s3.amazonaws.com/" % ] "" make ;
PRIVATE>

TUPLE: key name last-modified size ;

<PRIVATE
: (keys) ( xml -- seq )
    "Contents" tags-named [
        [ "Key" tag-named children>string ]
        [ "LastModified" tag-named children>string ]
        [ "Size" tag-named children>string ]
        tri key boa
    ] map ;
PRIVATE>

: keys ( bucket -- seq )
    "/" H{ } clone s3-get
    nip >string string>xml (keys) ;

: get-object ( bucket key -- response data )
    "/" prepend H{ } clone s3-get ;

: create-bucket ( bucket -- )
    "" swap "/" H{ } clone "PUT" <s3-request>
    "application/octet-stream" >>mime-type
    dup s3-url swapd <put-request>
    0 "content-length" set-header
    sign-http-request
    http-request 2drop ;

: delete-bucket ( bucket -- )
    "/" H{ } clone "DELETE" <s3-request>
    dup s3-url <delete-request> sign-http-request http-request 2drop ;

: put-object ( data mime-type bucket key headers -- )
    [ "/" prepend ] dip "PUT" <s3-request>
    over >>mime-type
    [ <post-data> swap >>data ] dip
    dup s3-url swapd <put-request>
    dup header>> pick headers>> assoc-union >>header
    sign-http-request
    http-request 2drop ;

: delete-object ( bucket key -- )
    "/" prepend H{ } clone "DELETE" <s3-request>
    dup s3-url <delete-request> sign-http-request http-request 2drop ;

: bucket>alist ( bucket -- alist )
    dup keys
    [ name>> get-object nip ] with zip-with ;

