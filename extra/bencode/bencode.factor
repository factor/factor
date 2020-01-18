USING: arrays assocs byte-arrays combinators io
io.encodings.binary io.streams.byte-array io.streams.string
kernel linked-assocs math math.parser sequences strings ;
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
    "e" read-until char: e assert= string>number ;

: read-list ( -- obj )
    [ read-bencode dup ] [ ] produce nip ;

: read-dictionary ( -- obj )
    [
        read-bencode [ read-bencode 2array ] [ f ] if* dup
    ] [ ] produce nip >linked-hash ;

: read-string ( prefix -- obj )
    ":" read-until char: \: assert= swap prefix
    string>number read "" like ;

PRIVATE>

: read-bencode ( -- obj )
    read1 {
        { char: i [ read-integer ] }
        { char: l [ read-list ] }
        { char: d [ read-dictionary ] }
        { char: e [ f ] }
        [ read-string ]
    } case ;

GENERIC: bencode> ( bencode -- obj )

M: byte-array bencode>
    binary [ read-bencode ] with-byte-reader ;

M: string bencode>
    [ read-bencode ] with-string-reader ;
