USING: kernel hashtables sequences io memoize arrays math namespaces shuffle ;
IN: case

! Admitted flaw in this program:
! conditional and locale-dependent special casing is ignored.
! This is an issue in Greek, Turkish, Azeri and Lithuanian
! in final sigma and in I or J with an accent mark

: data ( filename -- data )
    resource-path <file-reader> lines [ ";" split ] map ;

: load-data ( -- data )
    "libs/unicode/UnicodeData.txt" data ;

: process-data ( index data -- hash )
    [ [ nth ] keep first swap 2array ] map-with
    [ second empty? not ] subset
    [ [ hex> ] map ] map alist>hash ;

MEMO: case-mappings ( -- lower upper title )
    load-data
    [ 13 swap process-data ] keep
    [ 12 swap process-data ] keep
    14 swap process-data dupd hash-union ;
case-mappings 3drop

: simple-lower ( -- hash )
    case-mappings 2drop ;
: simple-upper ( -- hash )
    case-mappings drop nip ;
: simple-title ( -- hash )
    case-mappings 2nip ;

: hash-default ( key hash -- value/key )
    dupd hash [ nip ] when* ;

: uch>lower ( ch -- lower ) simple-lower hash-default ;
: uch>upper ( ch -- upper ) simple-upper hash-default ;
: uch>title ( ch -- title ) simple-title hash-default ;

: load-special-data ( -- data )
    "libs/unicode/SpecialCasing.txt" data
    [ length 5 = ] subset ;

: multihex ( hexstring -- string )
    " " split [ hex> ] map [ ] subset ;

TUPLE: code-point lower title upper ;
: set-code-point ( seq -- )
    4 head [ multihex ] map first4
    <code-point> swap first set ;

MEMO: special-casing ( -- hash )
    load-special-data [ [ set-code-point ] each ] make-hash ;
special-casing drop

: map-case ( string string-quot char-quot -- case )
    [
        rot [
            dup special-casing hash
            [ -rot drop call % ]
            [ -rot nip call , ] ?if
        ] each-with2
    ] { } make ; inline

: u>lower ( string -- lower )
    [ code-point-lower ] [ uch>lower ] map-case ;

: u>upper ( string -- upper )
    [ code-point-upper ] [ uch>upper ] map-case ;

: u>title ( string -- title )
    [ code-point-title ] [ uch>title ] map-case ;

