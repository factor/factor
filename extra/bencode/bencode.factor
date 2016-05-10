USING: arrays assocs combinators hashtables io
io.encodings.ascii io.encodings.string io.streams.string kernel
math math.parser sequences strings ;
IN: bencode

GENERIC: >bencode ( obj -- bencode )

M: integer >bencode
    number>string "i" "e" surround ;

M: string >bencode
    [ length number>string ":" ] keep 3append ;

M: sequence >bencode
    [ >bencode ] map concat "l" "e" surround ;

M: assoc >bencode
    [ [ >bencode ] bi@ append ] { } assoc>map concat
    "d" "e" surround ;

<PRIVATE

DEFER: read-bencode

: read-integer ( -- obj )
    "e" read-until CHAR: e assert= string>number ;

: read-list ( -- obj )
    [ read-bencode dup ] [ ] produce nip ;

: read-dictionary ( -- obj )
    [
        read-bencode [ read-bencode 2array ] [ f ] if* dup
    ] [ ] produce nip >hashtable ;

: read-string ( prefix -- obj )
    ":" read-until CHAR: : assert= swap prefix
    string>number read ascii decode ;

: read-bencode ( -- obj )
    read1 {
        { CHAR: i [ read-integer ] }
        { CHAR: l [ read-list ] }
        { CHAR: d [ read-dictionary ] }
        { CHAR: e [ f ] }
        [ read-string ]
    } case ;

PRIVATE>

: bencode> ( bencode -- obj )
    [ read-bencode ] with-string-reader ;
