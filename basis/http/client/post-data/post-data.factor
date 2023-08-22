! Copyright (C) 2009 Slava Pestov.
! See https://factorcode.org/license.txt for BSD license.
USING: accessors assocs destructors http io io.encodings.ascii
io.encodings.binary io.encodings.string io.encodings.utf8
io.files io.files.info io.pathnames kernel math.parser sequences
strings urls.encoding ;
IN: http.client.post-data

TUPLE: measured-stream stream size ;

C: <measured-stream> measured-stream

<PRIVATE

GENERIC: (set-post-data-headers) ( header data -- header )

M: sequence (set-post-data-headers)
    length "content-length" pick set-at ;

M: measured-stream (set-post-data-headers)
    size>> "content-length" pick set-at ;

M: object (set-post-data-headers)
    drop "chunked" "transfer-encoding" pick set-at ;

PRIVATE>

: set-post-data-headers ( header post-data -- header )
    [ data>> (set-post-data-headers) ]
    [ content-type>> "content-type" pick set-at ] bi ;

<PRIVATE

GENERIC: (write-post-data) ( data -- )

M: sequence (write-post-data) write ;

M: measured-stream (write-post-data)
    stream>> [ [ write ] each-block ] with-input-stream ;

: write-chunk ( chunk -- )
    [ length >hex ";\r\n" append ascii encode write ] [ write ] bi ;

M: object (write-post-data)
    [ [ write-chunk ] each-block ] with-input-stream
    "0;\r\n" ascii encode write ;

GENERIC: >post-data ( object -- post-data )

M: f >post-data ;

M: post-data >post-data ;

M: string >post-data
    utf8 encode
    "application/octet-stream" <post-data>
        swap >>data ;

M: assoc >post-data
    "application/x-www-form-urlencoded" <post-data>
        swap >>params ;

M: object >post-data
    "application/octet-stream" <post-data>
        swap >>data ;

: pathname>measured-stream ( pathname -- stream )
    string>>
    [ binary <file-reader> &dispose ]
    [ file-info size>> ] bi
    <measured-stream> ;

: normalize-post-data ( request -- request )
    dup post-data>> [
        dup params>> [
            assoc>query ascii encode >>data
        ] when*
        dup data>> pathname? [
            [ pathname>measured-stream ] change-data
        ] when
        drop
    ] when* ;

PRIVATE>

: unparse-post-data ( request -- request )
    [ >post-data ] change-post-data
    normalize-post-data ;

: write-post-data ( request -- request )
    dup post-data>> [ data>> (write-post-data) ] when* ;
