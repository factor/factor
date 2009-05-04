! Copyright (C) 2009 Doug Coleman.
! See http://factorcode.org/license.txt for BSD license.
USING: multiline kernel sequences io splitting fry namespaces
http.parsers hashtables assocs combinators ascii io.files.unique
accessors io.encodings.binary io.files byte-arrays math
io.streams.string combinators.short-circuit strings math.order
quoting ;
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
TUPLE: mime-variable headers key value ;

: <multipart> ( mime-separator -- multipart )
    multipart new
        swap >>mime-separator
        H{ } clone >>mime-parts ;

ERROR: bad-header bytes ;

: mime-write ( sequence -- )
    >byte-array write ;

: parse-headers ( string -- hashtable )
    string-lines harvest [ parse-header-line ] map >hashtable ;

ERROR: end-of-stream multipart ;

: fill-bytes ( multipart -- multipart )
    buffer-size read
    [ '[ _ append ] change-bytes ]
    [ t >>end-of-stream? ] if* ;

: maybe-fill-bytes ( multipart -- multipart )
    dup bytes>> length 256 < [ fill-bytes ] when ;

: split-bytes ( bytes separator -- leftover-bytes safe-to-dump )
    dupd [ length ] bi@ 1- - short cut-slice swap ;

: dump-until-separator ( multipart -- multipart )
    dup
    [ current-separator>> ] [ bytes>> ] bi
    [ nip ] [ start ] 2bi [
        cut-slice
        [ mime-write ]
        [ over current-separator>> length short tail-slice >>bytes ] bi*
    ] [
        drop
        dup [ bytes>> ] [ current-separator>> ] bi split-bytes mime-write
        >>bytes fill-bytes dup end-of-stream?>> [ dump-until-separator ] unless
    ] if* ;

: dump-string ( multipart separator -- multipart string )
    >>current-separator
    [ dump-until-separator ] with-string-writer ;

: read-header ( multipart -- multipart )
    maybe-fill-bytes
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
        [ [ header>> ] [ filename>> ] [ temp-file>> ] tri mime-file boa ]
        [ content-disposition>> "name" swap at unquote ]
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
    "factor-" "-upload" make-unique-file
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
    "content-disposition" over header>> at ";" split1 swap {
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
    <multipart> parse-beginning fill-bytes parse-multipart-loop
    mime-parts>> ;
