! Copyright (C) 2009 Doug Coleman.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors ascii assocs byte-arrays combinators hashtables
http http.parsers io io.encodings.binary io.files io.files.temp
io.files.unique io.streams.string kernel math quoting sequences
splitting ;
IN: mime.multipart

CONSTANT: buffer-size 65536
CONSTANT: separator-prefix "\r\n--"

TUPLE: multipart
end-of-stream?
current-separator mime-separator
header
content-disposition bytes
filename temp-file
name name-content
mime-parts ;

TUPLE: mime-file headers filename temporary-path ;
C: <mime-file> mime-file

TUPLE: mime-variable headers key value ;
C: <mime-variable> mime-variable

: <multipart> ( mime-separator -- multipart )
    multipart new
        swap >>mime-separator
        H{ } clone >>mime-parts ;

: mime-write ( sequence -- )
    >byte-array write ;

: parse-headers ( string -- hashtable )
    split-lines harvest [ parse-header-line ] map >hashtable ;

: fill-bytes ( multipart -- multipart )
    buffer-size read
    [ '[ _ B{ } append-as ] change-bytes ]
    [ t >>end-of-stream? ] if* ;

ERROR: mime-decoding-ran-out-of-bytes ;
: dump-until-separator ( multipart -- multipart )
    [ ] [ current-separator>> ] [ bytes>> ] tri
    dup [ mime-decoding-ran-out-of-bytes ] unless
    2dup swap subseq-index [
        cut-slice
        [ mime-write ]
        [ swap length tail-slice >>bytes ] bi*
    ] [
        tuck 2length - 1 - cut-slice
        [ mime-write ]
        [ >>bytes ] bi* fill-bytes
        dup end-of-stream?>> [ dump-until-separator ] unless
    ] if* ;

: dump-string ( multipart separator -- multipart string )
    >>current-separator
    [ dump-until-separator ] with-string-writer ;

: read-header ( multipart -- multipart )
    dup bytes>> "--\r\n" sequence= [
        t >>end-of-stream?
    ] [
        "\r\n\r\n" dump-string parse-headers >>header
    ] if ;

: empty-name? ( string -- ? )
    { "''" "\"\"" "" f } member? ;

: save-uploaded-file ( multipart -- )
    dup filename>> empty-name? [
        drop
    ] [
        [ [ header>> ] [ filename>> ] [ temp-file>> ] tri <mime-file> ]
        [ content-disposition>> "name" of unquote ]
        [ mime-parts>> set-at ] tri
    ] if ;

: save-mime-part ( multipart -- )
    dup name>> empty-name? [
        drop
    ] [
        [ name-content>> ]
        [ name>> unquote ]
        [ mime-parts>> set-at ] tri
    ] if ;

: dump-mime-file ( multipart filename -- multipart )
    binary <file-writer> [
        dup mime-separator>> >>current-separator dump-until-separator
    ] with-output-stream ;

: dump-file ( multipart -- multipart )
    [ "factor-" "-upload" unique-file ] with-temp-directory
    [ >>temp-file ] [ dump-mime-file ] bi ;

: parse-content-disposition-form-data ( string -- hashtable )
    ";" split
    [ "=" split1 [ [ blank? ] trim ] bi@ ] H{ } map>assoc ;

: lookup-disposition ( multipart string -- multipart value/f )
    over content-disposition>> at ;

ERROR: unknown-content-disposition multipart ;

: parse-form-data ( multipart -- multipart )
    "filename" lookup-disposition [
        unquote
        >>filename
        [ dump-file ] [ save-uploaded-file ] bi
    ] [
        "name" lookup-disposition [
            [ dup mime-separator>> dump-string >>name-content ] dip
            >>name dup save-mime-part
        ] [
             unknown-content-disposition
        ] if*
    ] if* ;

ERROR: no-content-disposition multipart ;

: process-header ( multipart -- multipart )
    dup "content-disposition" header ";" split1 swap {
        { "form-data" [
            parse-content-disposition-form-data >>content-disposition
            parse-form-data
        ] }
        [ no-content-disposition ]
    } case ;

: read-assert-sequence= ( sequence -- )
    [ length read ] keep assert-sequence= ;

: parse-beginning ( multipart -- multipart )
    "--" read-assert-sequence=
    dup mime-separator>>
    [ read-assert-sequence= ]
    [ separator-prefix prepend >>mime-separator ] bi ;

: parse-multipart-loop ( multipart -- multipart )
    read-header
    dup end-of-stream?>> [ process-header parse-multipart-loop ] unless ;

: parse-multipart ( separator -- mime-parts )
    <multipart> parse-beginning fill-bytes
    parse-multipart-loop mime-parts>> ;
