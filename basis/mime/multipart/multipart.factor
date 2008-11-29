! Copyright (C) 2008 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: accessors combinators io kernel locals math multiline
sequences splitting prettyprint namespaces http.parsers
ascii assocs unicode.case io.files.unique io.files io.encodings.binary
byte-arrays io.encodings make fry ;
IN: mime.multipart

TUPLE: multipart-stream stream n leftover separator ;

: <multipart-stream> ( stream separator -- multipart-stream )
    multipart-stream new
        swap >>separator
        swap >>stream
        16 2^ >>n ;

<PRIVATE

: ?append ( seq1 seq2 -- newseq/seq2 )
    over [ append ] [ nip ] if ;

: ?cut* ( seq n -- before after )
    over length over <= [ drop f swap ] [ cut* ] if ;
    
: read-n ( stream -- bytes end-stream? )
    [ f ] change-leftover
    [ n>> ] [ stream>> ] bi stream-read [ ?append ] keep not ;

: multipart-split ( bytes separator -- before after seq=? )
    2dup sequence= [ 2drop f f t ] [ split1 f ] if ;

:: multipart-step-found ( bytes stream quot: ( bytes -- ) -- ? )
    bytes [ quot unless-empty ]
    [ stream (>>leftover) quot unless-empty ] if-empty f ; inline

:: multipart-step-not-found ( bytes stream end-stream? separator quot: ( bytes -- ) -- ? )
    bytes end-stream? [
        quot unless-empty f
    ] [
        separator length 1- ?cut* stream (>>leftover)
        quot unless-empty t
    ] if ; inline

:: multipart-step ( stream bytes end-stream? separator quot: ( bytes -- ) -- ? end-stream? )
    #! return t to loop again
    bytes separator multipart-split
    [ 2drop f ]
    [
        [ stream quot multipart-step-found ]
        [ stream end-stream? separator quot multipart-step-not-found ] if*
    ] if stream leftover>> end-stream? not or >boolean ;


:: multipart-step-loop ( stream quot1: ( bytes -- ) -- ? )
    stream dup [ read-n ] [ separator>> ] bi quot1 multipart-step
    swap [ drop stream quot1 multipart-step-loop ] when ; inline recursive

PRIVATE>

SYMBOL: header
SYMBOL: parsed-header
SYMBOL: magic-separator

: trim-blanks ( str -- str' ) [ blank? ] trim ;

: trim-quotes ( str -- str' )
    [ [ CHAR: " = ] [ CHAR: ' = ] bi or ] trim ;

: parse-content-disposition ( str -- content-disposition hash )
    ";" split [ first ] [ rest-slice ] bi [ "=" split ] map
    [ [ trim-blanks ] [ trim-quotes ] bi* ] H{ } assoc-map-as ;

: parse-multipart-header ( string -- headers )
    "\r\n" split harvest
    [ parse-header-line first2 ] H{ } map>assoc ;

ERROR: expected-file ;

TUPLE: uploaded-file path filename name ;

: (parse-multipart) ( stream -- ? )
    "\r\n\r\n" >>separator
    header off
    dup [ header [ prepend ] change ] multipart-step-loop drop
    header get dup magic-separator get [ length ] bi@ < [
        2drop f
    ] [
        parse-multipart-header
        parsed-header set
        "\r\n" magic-separator get append >>separator
        "factor-upload" "httpd" make-unique-file tuck
        binary [ [ write ] multipart-step-loop ] with-file-writer swap
        "content-disposition" parsed-header get at parse-content-disposition
        nip [ "filename" swap at ] [ "name" swap at ] bi
        uploaded-file boa ,
    ] if ;

: parse-multipart ( stream -- array )
    [
        "\r\n" <multipart-stream>
        magic-separator off
        dup [ magic-separator [ prepend ] change ]
            multipart-step-loop drop
        '[ [ _ (parse-multipart) ] loop ] { } make
    ] with-scope ;
