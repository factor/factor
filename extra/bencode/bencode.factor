USING: arrays assocs byte-arrays combinators io
io.encodings.binary io.streams.byte-array io.streams.string
kernel linked-assocs math math.parser sequences sequences.extras strings ;
IN: bencode

GENERIC: >bencode ( obj -- bencode )

M: integer >bencode
    number>string "i" "e" surround ;

M: string >bencode
    [ length number>string ":" ] keep 3append ;

M: byte-array >bencode "" like >bencode ;

M: sequence >bencode
    [ >bencode ] map concat "l" "e" surround ;

M: assoc >bencode
    [ [ >bencode ] bi@ append ] { } assoc>map concat
    "d" "e" surround ;

DEFER: read-bencode

<PRIVATE

: read-integer ( -- obj )
    "e" read-until CHAR: e assert= string>number ;

: read-list ( -- obj )
    [ read-bencode ] loop>array ;

: read-dictionary ( -- obj )
    [
        read-bencode [ read-bencode 2array ] [ f ] if*
    ] loop>array >linked-hash ;

: read-string ( prefix -- obj )
    ":" read-until CHAR: : assert= swap prefix
    string>number read "" like ;

PRIVATE>

: read-bencode ( -- obj )
    read1 {
        { CHAR: i [ read-integer ] }
        { CHAR: l [ read-list ] }
        { CHAR: d [ read-dictionary ] }
        { CHAR: e [ f ] }
        [ read-string ]
    } case ;

GENERIC: bencode> ( bencode -- obj )

M: byte-array bencode>
    binary [ read-bencode ] with-byte-reader ;

M: string bencode>
    [ read-bencode ] with-string-reader ;
