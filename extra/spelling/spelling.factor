USING: arrays ascii assocs combinators combinators.smart fry
http.client io.encodings.ascii io.files io.files.temp kernel
locals math math.statistics memoize sequences sorting splitting
strings urls ;
IN: spelling

! http://norvig.com/spell-correct.html

CONSTANT: ALPHABET "abcdefghijklmnopqrstuvwxyz"

: splits ( word -- sequence )
    dup length iota [ cut 2array ] with map ;

: deletes ( sequence -- sequence' )
    [ second length 0 > ] filter [ first2 rest append ] map ;

: transposes ( sequence -- sequence' )
    [ second length 1 > ] filter [
        [
            {
                [ first ]
                [ second second 1string ]
                [ second first 1string ]
                [ second 2 tail ]
            } cleave
        ] "" append-outputs-as
    ] map ;

: replaces ( sequence -- sequence' )
    [ second length 0 > ] filter [
        [ ALPHABET ] dip first2
        '[ 1string _ _ rest surround ] { } map-as
    ] map concat ;

: inserts ( sequence -- sequence' )
    [
        ALPHABET
        [ [ first2 ] dip 1string glue ] with { } map-as
    ] map concat ;

: edits1 ( word -- edits )
    [
        splits {
            [ deletes ]
            [ transposes ]
            [ replaces ]
            [ inserts ]
        } cleave
    ] append-outputs ;

: edits2 ( word -- edits )
    edits1 [ edits1 ] map concat ;

: filter-known ( words dictionary -- words' )
    '[ _ key? ] filter ;

:: corrections ( word dictionary -- words )
    word 1array dictionary filter-known
    [ word edits1 dictionary filter-known ] when-empty
    [ word edits2 dictionary filter-known ] when-empty
    [ dictionary at 1 or ] sort-with ;

: words ( string -- words )
    >lower [ letter? not ] split-when harvest ;

: load-dictionary ( file -- assoc )
    ascii file-contents words histogram ;

MEMO: default-dictionary ( -- counts )
    "big.txt" temp-file dup exists?
    [ URL" http://norvig.com/big.txt" over download-to ] unless
    load-dictionary ;

: (correct) ( word dictionary -- word/f )
    corrections ?first ;

: correct ( word -- word/f )
    default-dictionary (correct) ;
