USING: kernel hashtables sequences io memoize arrays math namespaces shuffle strings assocs ;
IN: case

! Admitted flaw in this program:
! locale-dependent special casing is ignored.
! This is an issue in Turkish, Azeri and Lithuanian
! in I or J with an accent mark.
! Additionally, Conjoining Jamo behavior isn't
! yet implemented.
! Word boundaries aren't recognized.
! Normalization can be optimized if you know
! how a string is made.

: data ( filename -- data )
    resource-path <file-reader> lines [ ";" split ] map ;

: load-data ( -- data )
    "libs/unicode/UnicodeData.txt" data ;

: (process-data) ( index data -- newdata )
    [ [ nth ] keep first swap 2array ] map-with
    [ second empty? not ] subset ;

: process-data ( index data -- hash )
    (process-data)
    [ [ hex> ] map ] map >hashtable ;

: (chain-decomposed) ( hash value -- newvalue )
    [
        2dup swap at
        [ (chain-decomposed) ] [ 1array nip ] ?if
    ] map-with concat ;

: chain-decomposed ( hash -- newhash )
    dup [ >r over r> (chain-decomposed) ] assoc-map nip ;

: first* ( seq -- ? )
    second dup empty? [ drop t ] [ first ] if ;

: (process-decomposed) ( data -- alist )
    5 swap (process-data)
    [
        first2 >r hex> r>
        " " split
        [ hex> ] map
        2array
    ] map ;

: process-canonical ( data -- hash )
    (process-decomposed) [ first* ] subset
    >hashtable chain-decomposed ;

: process-compatability ( data -- hash )
    (process-decomposed)
    [ dup first* [ first2 1 tail 2array ] unless ] map
    >hashtable chain-decomposed ;

: process-combining ( data -- hash )
    3 swap (process-data)
    [ first2 >r hex> r> string>number 2array ] map
    [ second 0 = not ] subset
    >hashtable ;

MEMO: case-mappings ( -- mappings )
    load-data
    [
        13 over process-data , ! lower case
        12 over process-data tuck , ! upper case
        14 over process-data swapd union , ! title case
        dup process-combining , ! combining class
        dup process-canonical , ! canonical mapping
        process-compatability , ! compatability mapping
    ] { } make ;
case-mappings drop

: simple-lower ( -- hash )
    case-mappings first ;
: simple-upper ( -- hash )
    case-mappings second ;
: simple-title ( -- hash )
    case-mappings third ;
: canonical-entry ( -- seq )
    4 case-mappings nth at ;
: compatability-entry ( -- seq )
    5 case-mappings nth at ;
: combining-class ( char -- n )
    case-mappings fourth at ;

: hash-default ( key hash -- value/key )
    dupd at [ nip ] when* ;

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
    load-special-data [ [ set-code-point ] each ] H{ } make-assoc ;
special-casing drop

: map-with-next ( seq quot -- newseq )
    ! quot: next-elt elt -- newelt
    swap dup 1 tail-slice CHAR: \s add
    swap rot 2map ; inline

: final-sigma ( string -- string )
    ! Word boundaries aren't properly implemented here
    [
        swap dup blank? swap not or
        [ drop HEX: 3C2 ] when
    ] map-with-next ;

: map-case ( string string-quot char-quot -- case )
    [
        rot [
            dup special-casing at
            [ -rot drop call % ]
            [ -rot nip call , ] ?if
        ] each-with2
    ] "" make ; inline

: u>lower ( string -- lower )
    HEX: 3A3 over member? [ final-sigma ] when
    [ code-point-lower ] [ uch>lower ] map-case ;

: u>upper ( string -- upper )
    [ code-point-upper ] [ uch>upper ] map-case ;

: u>title ( string -- title )
    ! For legal purposes, this is not Unicode title case
    ! (It doesn't detect word boundaries properly)
    ! (For example, "xYz.aBc" >title ==> "Xyz.abc", not "Xyz.Abc")
    CHAR: \s swap >array [
        tuck swap blank? [
            dup special-casing at
            [ code-point-title ] [ uch>title 1array ] ?if
        ] [
            dup special-casing at
            [ code-point-lower ] [ uch>lower 1array ] ?if
        ] if
    ] map concat >string nip ;

: u>case-fold ( string -- fold )
    u>upper u>lower ;

: insensitive= ( str1 str2 -- ? )
    [ u>case-fold ] 2apply = ;

: lower? ( string -- ? )
    dup u>lower = ;
: upper? ( string -- ? )
    dup u>lower = ;
: title? ( string -- ? )
    dup u>title = ;
: case-fold? ( string -- ? )
    dup u>case-fold = ;

: 2apply-with ( obj 1 2 quot -- new1 new2 )
    tuck >r >r pick r> r> 3slip call ; inline

: (insert) ( seq n quot -- )
    over 0 = [ 3drop ] [
        [ >r dup 1- [ swap nth ] 2apply-with r> 2apply > ] 3keep
        roll [ 3drop ]
        [ >r [ dup 1- rot exchange ] 2keep 1- r> (insert) ] if
    ] if ; inline

: insert ( seq quot elt n -- )
    swap rot >r -rot [ swap set-nth ] 2keep r> (insert) ; inline

: insertion-sort ( seq quot -- ) ! quot is a transformation on elements
    over dup length [ >r >r 2dup r> r> insert ] 2each 2drop ; inline

: reorder ( string -- string )
    dup -1 over dup length [
        {
            { [ swap combining-class ] [ or ] }
            { [ over not ] [ drop ] }
            { [ 2dup swap - 1 <= ] [ 2drop f ] }
            { [ t ] [
                pick <slice>
                [ combining-class ] insertion-sort
            ] }
        } cond
    ] 2each
    over peek combining-class over and [
        dup -1 = [ drop 0 ] when
        over length pick <slice>
        [ combining-class ] insertion-sort dup
    ] when 2drop ;

: decompose ( string quot -- decomposed )
    over [ 127 < ] all? [ drop ] [
        2dup contains? [
            swap [ [
                dup rot call [ % ] [ , ] ?if
            ] each-with ] "" make
        ] [ drop ] if reorder
    ] if ; inline

: nfd ( string -- string )
    [ canonical-entry ] decompose ;

: nfkd ( string -- string )
    [ compatability-entry ] decompose ;
